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

MY_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1 |  tr -d '[[:space:]]'`
GATEWAY_IP=$1

ufw --force enable
ufw default allow incoming

sleep 5

consul agent -data-dir /tmp/consul -node=agent-one \
    -bind=$MY_IP -client=0.0.0.0 \
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
docker run -d -h $MY_IP \
    --name=registrator \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$MY_IP:8500

echo Running cAdvisor...
docker run --volume=/:/rootfs:ro \
    --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
    --publish=8080:8080 \
    --detach=true --name=cadvisor google/cadvisor:latest

echo Installing Docker Swarm...
docker pull swarm
docker run -d swarm join --advertise=$MY_IP:2375 consul://$GATEWAY_IP:8500


docker pull ghost
cd /build/agent-one
export DOCKER_HOST=tcp://$GATEWAY_IP:4000
docker-compose scale ghost=1
