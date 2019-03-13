# cluster
WCMC ansible based KVM cluster

## 1. preparation

- install ansible localy
- clone the git repo
- cd cluster/kvm-cluster
- ansible-galaxy install -r requirements

## 2. installing/updating the kvm-cluster

- make sure your barebone inventory list matches your local env
- ansible-playbook -i barebone.inventory --ask-sudo-pass kvm_cluster_playbook.yml

This should now provide you with a complete install of your cluster.

### What does this do

- setup user accounts
- install docker
- configure a docker swarm
- install a kvm env
- format and mount kvm storage
- configure kvm storage pool
- setup a swarmprom monitoring service
