FROM eclipse-temurin

ARG MINECRAFT_SERVER_VERSION="1.18.2"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y jq 
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

RUN mkdir /opt/minecraft_server
WORKDIR /opt/minecraft_server

RUN curl https://piston-meta.mojang.com/mc/game/version_manifest_v2.json --output version_manifest_v2.json && \
    cat version_manifest_v2.json | jq -r '.versions|.[]| select(.id == "'$MINECRAFT_SERVER_VERSION'" ) | .url' \
        | xargs curl --output version_package.json && \
    cat version_package.json | jq -r '.downloads | .server | .url' > dl_url && \
    curl $(cat dl_url) --output /opt/minecraft_server/server.jar

# this expects a volume with the server data to be mounted at /mnt/minecraft_server_data
WORKDIR /mnt/minecraft_server_data
CMD ["java", "-Xmx2048m", "-Xms2048m", "-jar", "/opt/minecraft_server/server.jar", "nogui"]
