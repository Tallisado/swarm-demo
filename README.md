![Microservices with Docker Swarm and Consul](https://sonnguyen.ws/wp-content/uploads/2015/12/clotify_microservice.png)

# DEMO - Part One

## Tooling
- Docker-Toolbox
- Docker-Machine
- PaaS - Digital Ocean

# DEMO - Part Two
## Tooling
- Swarm -> Cluster together docker hosts
- Consul -> Service Discovery (not using DNS portion)
- Consul-Template -> Template Rendering
- NGINX -> Load Balancing
- cAdvisor -> Resource Usage Analysis

### Create and Provision VMs

```
export TOKEN=bf8e0947b47761c61a3e12b402c127ac66f11768f8c07152649d33a263dd0b60
```

#### Create GATEWAY
```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=debian-8-x64 \
--digitalocean-region=tor1 \
 gateway
```
#### Create NODE1

```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=ubuntu-14-04-x64 \
--digitalocean-region=tor1 \
 node1
```

#### Create NODE2

```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=ubuntu-14-04-x64 \
--digitalocean-region=tor1 \
 node2
```

#### Deploy Services (GATEWAY)
```
docker-machine ssh gateway
mkdir /build
git clone https://github.com/Tallisado/swarm-demo.git /build
cd /build/gateway
chmod +x run.sh
./run.sh
```

#### Deploy Services (NODE1)
```
export GATEWAY_IP=`docker-machine inspect gateway | grep IPAddress | tr -d '[[:space:]]' | cut -d':' -f2 | cut -d'"' -f2`
docker-machine ssh node1 "mkdir /build; git clone https://github.com/Tallisado/swarm-demo.git /build; cd /build/agent-one; chmod +x run.sh; ./run.sh $GATEWAY_IP"
```

#### Deploy Services (NODE[n])
##### Node 2 -- But this can be repeated as many times as needed
```
export GATEWAY_IP=`docker-machine inspect gateway | grep IPAddress | tr -d '[[:space:]]' | cut -d':' -f2 | cut -d'"' -f2`
docker-machine ssh node2 "mkdir /build; git clone https://github.com/Tallisado/swarm-demo.git /build; cd /build/agent-two; chmod +x run.sh; ./run.sh $GATEWAY_IP"
```

##### Node X -- Repeated as many times as needed
```
export NODE=node3
export GATEWAY_IP=`docker-machine inspect gateway | grep IPAddress | tr -d '[[:space:]]' | cut -d':' -f2 | cut -d'"' -f2`
docker-machine ssh $NODE "mkdir /build; git clone https://github.com/Tallisado/swarm-demo.git /build; cd /build/agent-two; chmod +x run.sh; ./run.sh $GATEWAY_IP"
```

# Let's see the VMs using docker machine

- docker-machine ssh gateway
- docker-machine ls

```
EXAMPLE:
agent-one  159.203.27.163:8301  alive   client  0.6.0  2         dc1
agent-two  159.203.27.168:8301  alive   client  0.6.0  2         dc1
gateway    159.203.27.156:8301  alive   server  0.6.0  2         dc1
```

## GHOST
- on node1
```
export DOCKER_HOST=tcp://$MY_IP:12375
docker-compose ps
```
- THEIP:THEGHOSTPORT

## GHOST THROUGH NGINX
- GATEWAYIP (defaults to port 80)

## Lets scale a few containers across out nodes
```
docker-compose scale ghost=5
```

## Now when we refresh the page, nginx will load balance across all the containers. These could be living in different DataCenters!
```
docker-compose logs ghost
```

- docker-compose scale ghost=2
- docker-compose ps
- removed containers from nodes dynamically
