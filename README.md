# minecraft server in podman container

a minimal minecraft java server setup in a podman container

## build

podman build --tag minecraft_server .

## add existing server data

podman volume create minecraft_server_data
podman unshare
podman volume mount minecraft_server_data

add data to the mounted dir

## run

podman run --rm \
    --name minecraft_server \
    --mount type=volume,src=minecraft_server_data,target=/mnt/minecraft_server_data \
    minecraft_server


## backup

podman run --rm --volumes-from minecraft_server -v $(pwd)/backup:/backup:z eclipse-temurin tar cvf /backup/backup.tar /mnt/minecraft_server
