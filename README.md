# How to Event Mesh Solace PubSub+ VMRs via external links using TLS and cert-auth

These Linux scripts can be used to create an Event Mesh of two or more clusters configured to use SSL and client certificate auth.  

## Prerequisites

Before running any of these scripts, you must ensure that the following conditions are satisfied on each of the PubSub+ VMRs you intend to use to create DMR enabled clusters:
- PubSub+ Docker Container Configurations
  * Set shm_size to 2gb+ 
  * Set max client connections to at least 1000
  * Set the router name of your PubSub+ VMR to match its respective cluster 
  * Open port 943 for SEMP over TLS
  * Open port 55443 for SMF over TLS
  * Open the ports required for the protocol of choice over TLS
- TLS Certs
  * Have verified server-certs for TLS installed
  * Have a central CA cert installed 
  * Enable client-cert authentication on all message-vpns that will be connected via a TLS enabled external link

For help setting up the certificates, you can check out [TLS Helper Scripts](https://github.com/koverton/TLS-Helper-Scripts).

For help setting up the PubSub+ docker container configurations, you can check out [a non-existent link](google.com).

## Terminology

If you're not familiar with the terms Event Mesh or DMR, check out:
- [What's an Event Mesh?](https://docs.solace.com/Overviews/DMR-Overview.htm#contentBody)  
- [DMR Overview](https://docs.solace.com/Overviews/DMR-Overview.htm#contentBody)

## Visual Aids 

If you're reading this guide, it'll help to have a visual in your mind before you jump in and try to get these scripts to work.  
</br>
   
Example of a hybrid cloud Event Mesh.
![img not found](/docs/event-mesh-simple.png "Example Hybrid Cloud Event Mesh")
</br>   
      
Example topology of a simple DMR configuration   
![img not found](/docs/dmr-simple-config.png "Example DMR Configuration Structure")   

## Getting Started

### Functions

`dmr_funcs.sh`

This script contains a collection of functions required to create or destroy clusters, links, and channels.  As depicted in the example DMR configuration structure, you'll need all three types of objects to create an Event Mesh of clusters.

`create_cluster <host> <cluster> <cert> <cname>`

This function creates a cluster using the provided cluster name on the provided host.  The cluster will be configured to use the provided server certificate and will identify as the provided cname.

`create_link <host> <local-cluster> <remote-cluster> <connect-via> <cname>`

This function uses the provided host to send commands via SEMP (Solace Element Management Protocol) to create a link between the provided local cluster and remote cluster.  Connect-via specifies the IP address where the local cluster can expect to find the remote cluster, and cname specifies the cname that the local cluster will expect from the remote cluster.

`create_channel <host> <local-msg-vpn> <remote-cluster> <remote-msg-vpn>`

This function uses the provided host to send commands via SEMP (Solace Element Management Protocol) to create a channel between the provided local message vpn and the provided remote message vpn on the provided remote cluster.  

### Example Scripts

Included in this repository are two example scripts that utilize all three of the required functions to create an Event Mesh of Solace PubSub+ VMRs via external links using TLS and cert-auth.  

```
aws_blue_cluster.sh
aws_red_cluster.sh
```

Each script includes a set of steps for their respective create and destroy functions that you'll need to modify to include the IP of your preconfigured hosts.  If you've correctly configured your hosts as specified by the prerequisites section, running the create functions found in both scripts will create a usable Event Mesh consisting of two clusters.  Running the destroy scripts will cleanup any created resources on your brokers.
