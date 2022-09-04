# minecraft server in podman container

a minimal minecraft java server setup in a podman container

backup is not yet figured out
sending full volume snapshots as tar is very bandwidth inefficient
it also requires multiple copies of the data

a decent solution is, using a bind mount instead of volumes and rsyncing the directory
bind mounts are unfit for a containerized cloud though, and is not very safe when files are written to

one alternative i want to try is to use a btrfs volume driver,
snapshotting the volume and rsyncing the snapshot or using some btrfs transfer function

## build

podman build --tag minecraft_server .

also install pipe-viewer for limiting pipe speed
dnf install pv

## add existing server data

podman volume create minecraft_server_data
podman unshare
podman volume mount minecraft_server_data

then add data to the mounted dir

or restore from backup 

## run

podman run --name minecraft_server \
    --mount type=volume,src=minecraft_server_data,target=/mnt/minecraft_server_data \
    -p 26998:26998 \
    minecraft_server

## backup

podman run --rm \
    --volumes-from minecraft_server \
    -v /root/minecraft_server_data/backup:/backup:z eclipse-temurin \
    tar cvf /backup/backup.tar /mnt/minecraft_server_data

or simpler:
podman volume export minecraft_server_data -o minecraft_server_data.tar | tar xf - --directory backup

## restore from backup

podman run --rm \
    --volumes-from minecraft_server \
    -v /root/minecraft_server_data/backup:/backup:z eclipse-temurin \
    bash -c "cd /mnt/minecraft_server_data && tar xvf /backup/backup.tar --strip 1"

or simpler:
tar -C /root/backup -c . --to-stdout | podman volume import minecraft_server_data -

## install system service
the container has to be run as above and not be removed
then:

recommended generate systemd unit on the fly:
podman generate systemd --name minecraft_server > /etc/systemd/system/minecraft_server.service

systemctl enable minecraft_server.service
systemctl start minecraft_server.service

## other miscelanous info

the base docker image is eclipse-temurin which is based on ubuntu
