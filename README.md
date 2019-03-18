# cluster

This provides you with a barebone cluster setup to provision N KVM's for each physical node. The idea is than to expose these generated nodes in
an internal docker-swarm cluster. To decouple it from the physical hardware layer and provide an unified presentation to any application running
and to easily replace cheap, used hardware.

It is possible to utilize non identical hardware for the KVM cluster, by specifying a specific configuration for each host, which will overwrite the
central group configurations

### We personally recommend a layout on each node of:

- 60% resources for production
- 20% resources for testing
- 10% resources for developments

Which will provide you with a basic architecture to work off.

## 1. preparation

- install ansible localy. We require version 2.8 dev! So needs to be setup accordingly to the instations on the ansible webpage
- clone the git repo
- cd cluster/kvm-cluster
- ansible-galaxy install -r requirements

## 2. installing/updating the kvm-cluster

- make sure your barebone inventory list matches your local env
- configure your group_vars/kvm_node.yml to represent your local setup
- ansible-playbook -i barebone.inventory --become --ask-become-pass kvm_cluster_playbook.yml

This should now provide you with a complete install of your cluster.

### Requirements:

1. 2+ HP Proliant G7/G8 servers (GLUSTERFS will not work with a single host)
2. main drive at /dev/sda*
3. drive for kvm and glusterfs. Please ensure this drive has no partitions, we will define these automatically during the setup. If you want to force deletion of partions, apply the --tags force_reset option
4. switch with support for VLANS
5. 4x1GB on board network cards, which will be bonded

### Vlans:

This setup is defined around 5 dedicated vlans:

1. ID:1 for the default VLAN utilized to setup the cluster, this should be a static ip address
2. ID:100 for the production system
3. ID:101 for the test system
4. ID:102 for shared services, which production and test need access for
5. ID:103 for data transfer and backup. This is a dedicated vlan, which is only used for glusterfs and NAS services.

### What does this do

- setup user accounts
- install docker
- configure a docker swarm
- install a kvm env
- format and mount kvm storage (YOU WILL LOOSE ALL DATA ON THIS DRIVE!)
    - 70% for KVM storage
    - 30% for a glusterfs backup system
- configure kvm storage pool
- setup a swarmprom monitoring service
- setup an elastic search logstash environment
- tie the physical cluster and logical clusters logging together. To avoid redundant services
