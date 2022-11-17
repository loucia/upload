FROM maven:3-jdk-11 as builder

ARG HTTP_PROXY=""
ARG HTTP_PROXY_HOST=""
ARG HTTP_PROXY_PORT=""
ARG TAG_VERSION="1.0.0"
ARG TAG_BUILD="000"
ARG TAG_COMMIT="NOT DEFINED"
ARG BUILD_DATE="NOT DEFINED"
ARG artifactory_username=""
ARG artifactory_apikey=""

ENV ARTIFACTORY_USER=$artifactory_username
ENV ARTIFACTORY_APIKEY=$artifactory_apikey

WORKDIR /usr/src

COPY . .

RUN HTTP_PROXY_HOST=$(echo $http_proxy | sed -E "s/^(http?:\/\/)?([^:]+):([0-9]+)/\2/")
RUN HTTP_PROXY_PORT=$(echo $http_proxy | sed -E "s/^(http?:\/\/)?([^:]+):([0-9]+)/\3/")
RUN mvn -Dhttp.proxyHost=${HTTP_PROXY_HOST} -Dhttp.proxyPort=${HTTP_PROXY_PORT} \
        -Dhttps.proxyHost=${HTTP_PROXY_HOST} -Dhttps.proxyPort=${HTTP_PROXY_PORT}  \
        -s settings.xml package -DskipTestssettings.xml


FROM adoptopenjdk/openjdk11-openj9:alpine-jre

LABEL sia="rtm"
LABEL irn="62991"
LABEL maintainer="aitslab@renaul-digital.com"
LABEL commit="${TAG_COMMIT}"
LABEL version="${TAG_VERSION}"
LABEL path_dockerfile "/home/Dockerfile"

ENV TERM=xterm
ENV SIA="rntbci-hackaton"
ENV IRN=""
ENV APP_NAME="quicktech-bot-api"
ENV TAG_COMMIT="${TAG_COMMIT}"
ENV BUILD_DATE="${BUILD_DATE}"
ENV TAG_VERSION="${TAG_VERSION}"
ENV TAG_BUILD="${TAG_BUILD}"




COPY --from=builder /usr/src/target/spring-boot-upload-files-0.0.1-SNAPSHOT-*.jar quicktechbot.jar
EXPOSE 8080
CMD java $JAVA_OPTIONS -jar quicktechbot.jar
