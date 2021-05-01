# Build Stage for Spring boot application image
FROM maven:3.5-jdk-8-alpine as build

WORKDIR /app


COPY pom.xml .


COPY src src

RUN mvn package

RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# Production Stage for Spring boot application image
FROM openjdk:8-jre-alpine as production
ARG DEPENDENCY=/app/target/dependency

# Copy the dependency application file from build stage artifact
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Run the Spring boot application
ENTRYPOINT ["java", "-cp", "app:app/lib/*","com.vaccine.notifier.vaccinenotifier.VaccineNotifierApplication"]
