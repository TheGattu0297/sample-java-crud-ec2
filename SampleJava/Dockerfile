# Stage 1: BUILD
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: RUN
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/product-crud.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]




