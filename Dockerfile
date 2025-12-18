# Image Java officielle
FROM openjdk:17-jdk-slim

# Dossier de travail dans le conteneur
WORKDIR /app

# Copier le JAR généré par Maven
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

# Exposer le port Spring Boot
EXPOSE 8080

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
