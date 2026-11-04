# Usa una imagen oficial ligera con Java 21
FROM eclipse-temurin:21-jdk-alpine AS build

# Crea el directorio de trabajo
WORKDIR /app

# Copia los archivos de Maven
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml ./

# Descarga las dependencias (cacheado para compilar más rápido)
RUN ./mvnw dependency:go-offline

# Copia el código de la app
COPY src src

# Empaqueta la aplicación generando el archivo .jar
RUN ./mvnw clean package -DskipTests

# --- Segunda etapa: Imagen final para ejecución ---
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copia el JAR generado en la compilación
COPY --from=build /app/target/*.jar app.jar

# Expone el puerto donde corre Spring Boot
EXPOSE 8080

# Comando para ejecutar la aplicación cuando encienda el contenedor
ENTRYPOINT ["java", "-jar", "app.jar"]
