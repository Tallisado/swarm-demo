A example for running your microservices. You just need to checkout this code and run:
```
vagrant up
```

![Microservices with Docker Swarm and Consul](https://sonnguyen.ws/wp-content/uploads/2015/12/clotify_microservice.png)


## Digital Ocean
### Create and Provision VMs

```
export TOKEN=1ec4ee2efb062f7103691d7a0cdf98489a593991e9cba1f8871ffa84cfb31fbc
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
