consul-cluster
==============

This repo is designed to work with the [CloudCoreo](http://www.cloudcoreo.com) engine. 

## Description
Highly Available, self-healing consul cluster configuration and setup

Consul is an awesome product from the guys over at Hashicorp. It is a key/value store and service discovery mechanism (like zookeeper) as well as health-checker and DNS provider. It's also ready to support multiple datacenters out of the box.

This [CloudCoreo](http://www.cloudcoreo.com) stack provides a production-ready Consul Server Cluster that is self-healing and highly available. If defaults are left as is, your environment will launch a cluster of 3 t2.small instances.

## How does it work?
You must provide a route53 dns zone for us to add an entry to. This will be a CNAME pointing to an internal ELB. The internal ELB will provide healthchecks for the consul servers and automatically replace failed nodes. The url will be dictated by the variable: `CONSUL_NAME` which defaults to "consul".

i.e. if your `CONSUL_NAME` is left as the default "consul", your consul cluster UI will be available at http://consul.<dns_name>

This is a private ELB so you can only access via VPN or bastion depending on how your network is set up.

When a failre even takes place, the Autoscaling group will replace the failed node. The addition of a new node triggers a clean up process approximately 60 seconds after boot is complete.

## REQUIRED VARIABLES
### `DNS_ZONE`:
  * required: true
  * description: the route53 dns zone to add the consul entry to.

## OVERRIDE OPTIONAL VARIABLES
### `CONSUL_INGRESS_CIDRS`:
  * default:
    * 10.11.0.0/16
  * description: cidrs that can access the consul server
  * type: array
  * required: true
### `CONSUL_NAME`:
  * default: consul
  * description: name of the consul server
  * required: true
### `CONSUL_AMI`:
  * default: ami-1ecae776
  * description: the ami to launch for consul - default is Amazon Linux AMI 2015.03 (HVM), SSD Volume Type
  * type: string
  * required: true
### `CONSUL_SIZE`:
  * default: t2.small
  * description: the image size to launch
  * required: true
### `CONSUL_KEY`:
  * default: ""
  * description: the ssh key to associate with the instance(s) - blank will disable ssh
  * type: string
  * required: false
### `CONSUL_GROUP_SIZE_MIN`:
  * default: 3
  * description: the minimum number of instances to launch
  * type: number
  * required: true
### `CONSUL_GROUP_SIZE_MAX`:
  * default: 5
  * description: the maxmium number of instances to launch
  * type: number
  * required: true


## Tags
1. Service Discovery
1. DNS
1. Monitoring
1. Hashicorp
1. High Availability

## Diagram
![alt text](https://raw.githubusercontent.com/CloudCoreo/consul-cluster/master/images/consul-diagram.png "Consul Cluster Diagram")

## Icon
![alt text](https://raw.githubusercontent.com/CloudCoreo/consul-cluster/master/images/consul.png "Consul icon")
