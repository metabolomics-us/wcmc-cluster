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


### Requirements:

1. 2+ HP Proliant G7/G8 servers (GLUSTERFS will not work with a single host)
2. main drive at /dev/sda*
3. drive for kvm and glusterfs. Please ensure this drive has no partitions, we will define these automatically during the setup. If you want to force deletion of partions, apply the --tags force_reset option
4. switch with support for VLANS
5. 4x1GB on board network cards, which will be bonded
6. Ansible 2.8
7. correctly configured dns server, which automatically registers the names of the generated kvm-vm machines.


### What does this do on the barebone servers

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

### Inventory

During the installation process, you will have several new inventory files being generated, following the following pattern

```cluster-<GROUP>_cluster.ini```

which will each define one virtualized cluster. These inventory files can than utilized to actually setup these virtual hosts
as desired.

We recommend to define specific playbooks for this, outside of this repo.


### Example deployment of a test cluster

1. copy 'test_cluster.yml' to 'my_test_cluster.yml'
2. add roles to 'my_test_cluster.yml'
3. 

```bash

ansible-playbook -i cluster-test_cluster.ini --become my_test_cluster.yml

```

Please ensure that all roles are locally in the playbook, or in a requirements-test.yml file. Which is required to be installed with

```bash
ansible-galaxy install -r requirements-test.yml
```