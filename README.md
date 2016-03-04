A example for running your microservices. You just need to checkout this code and run:
```
vagrant up
```

![Microservices with Docker Swarm and Consul](https://sonnguyen.ws/wp-content/uploads/2015/12/clotify_microservice.png)


## Digital Ocean
### Create and Provision VMs

```
export TOKEN=bf8e0947b47761c61a3e12b402c127ac66f11768f8c07152649d33a263dd0b60
```

```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=debian-8-x64 \
--digitalocean-region=tor1 \
 gateway
```

```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=ubuntu-14-04-x64 \
--digitalocean-region=tor1 \
 node1
```

```
docker-machine create --driver digitalocean \
--digitalocean-access-token=$TOKEN \
--digitalocean-image=ubuntu-14-04-x64 \
--digitalocean-region=tor1 \
 node2
```

## Services (Some containerized)

### Gateway
- Consul : Service Discovery
- Consul-Template : Live Configuration Updating
- NGINX : Load Balancing

```
docker-machine ssh gateway
mkdir /build
git clone https://github.com/Tallisado/swarm-demo.git /build
cd /build/gateway
chmod +x run.sh
./run.sh
```

### Node

```
docker-machine ssh node1
mkdir /build
git clone https://github.com/Tallisado/swarm-demo.git /build
cd /build/agent-one
chmod +x run.sh
./run.sh
```
