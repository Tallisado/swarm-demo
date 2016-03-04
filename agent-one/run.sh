#!/bin/bash

# echo Fetching swarm from my git ...
# cp /build/agent-one/init/*.conf /etc/init/

echo Installing dependencies...
apt-get update && \
    apt-get install -y unzip curl wget

echo Fetching Consul...
cd /tmp/
wget https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip -O consul.zip

echo Installing Consul...
unzip consul.zip
chmod +x consul
mv consul /usr/bin/consul
cp -R /build/agent-one/consul.d /etc/

MYIP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1 |  tr -d '[[:space:]]'`
GATEWAY_IP=$1

ufw --force enable
ufw default allow incoming

sleep 5

consul agent -data-dir /tmp/consul -node=agent-one \
    -bind=$MYIP -client=0.0.0.0 \
	-config-dir /etc/consul.d \
    -retry-join $GATEWAY_IP \
    &

echo Installing Docker ...
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" \
    > /etc/apt/sources.list.d/docker.list

apt-get update && \
    apt-get install -y linux-image-extra-$(uname -r)

apt-get update && \
    apt-get install -y docker-engine

cp /build/agent-one/docker /etc/default/docker
service docker restart

echo Installing Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo Running Registrator...
docker run -d -h $MYIP \
    --name=registrator \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$MYIP:8500

sleep 5
echo Running cAdvisor...
docker run --volume=/:/rootfs:ro \
    --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
    --publish=8080:8080 \
    --detach=true --name=cadvisor google/cadvisor:latest

echo Installing Docker Swarm...
docker pull swarm

docker run -d --name swarm_joiner swarm join \
    --addr=$MYIP:2375 \
    token://acdb9dfa3ea6da0b0cfb2c819385fcd3

sleep 5

docker run -d -p 12375:2375 --name swarm_manager \
    swarm manage token://acdb9dfa3ea6da0b0cfb2c819385fcd3
#
# echo Running Mysql...

cd /build/agent-one
export DOCKER_HOST=tcp://$MYIP:12375


# echo Running angular-admin-seed...
docker pull ghost
export DOCKER_HOST=tcp://$MYIP:12375
echo Docker Info...
# while true; do
#     if !docker info | grep "$MYIP" > /dev/null; then
#         echo Waiting for Swarm Manager working...
#         sleep 2;
#     else
#         break
#     fi;
# done
sleep 10
docker-compose scale ghost=1
