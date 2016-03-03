#!/bin/bash
echo Installing dependencies...
apt-get update && \
    apt-get install -y unzip curl wget nginx

echo Fetching Consul...
cd /tmp/
wget https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip -O consul.zip

echo Installing Consul...
unzip consul.zip
chmod +x consul
mv consul /usr/bin/consul
mkdir /etc/consul.d
chmod a+w /etc/consul.d

echo Fetching Consul UI...
cd /opt
mkdir consul
cd /opt/consul
wget https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_web_ui.zip -O consul_web_ui.zip
unzip consul_web_ui.zip

echo Fetching Consul Template...
cd /tmp/
wget https://releases.hashicorp.com/consul-template/0.12.0/consul-template_0.12.0_linux_amd64.zip -O consul-template.zip

echo Installing Consul Template...
unzip consul-template.zip
chmod +x consul-template
mv consul-template /usr/bin/consul-template

MYIP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1 |  tr -d '[[:space:]]'`

consul agent -server -bootstrap-expect 1 \
	-data-dir /tmp/consul -node=gateway -bind=$MYIP \
	-client=0.0.0.0 \
	-config-dir /etc/consul.d -ui-dir /opt/consul/

consul-template \
    -consul 127.0.0.1:8500 \
    -template "/build/swarm-demo/gateway/consul-template/nginx.ctmpl:/etc/nginx/sites-available/default:service nginx reload" \
    -retry 30s
