# Group Vars

All the yaml files in this directory are specific for the given group of the host files. And there should always be a couple of standard groupds

##all.yml

This file will apply to every single host in your inventory and the most important setting, is that you specify
the accounts and associated public key ssh-keys.

##kvm_node.yml

This files defines the configuration for the actual hardware, which will be used to provision the virtual machines, using the KVM hypervisor. These should be as identical as possible!

### critical sections:

####network:
 
this defines the network layout and configuration and needs to reflect your local network topology, vlans, etc.

####virtual_machines:

this defines how you want to layout your virtual machines and should contains basic informations like name, cpu's, memory and association to which cluster they belong

```.env
virtual_machines:

  - machine:
    name: test-2x4
    cpus: 2
    memory: 4096
    storage_size: 80000
    network: br.test
    pool: nvme
    group: test_cluster
    domain: test.fiehnlab.ucdavis.edu
    manager_possible: true # possible to be a manager, if running on a manager node
```

This for examples defines that:

1. we have the name test-2x4 as
2. we want to utilize 2 cpus
3. we want to utilize 4GB of memory
4. we want to utilize 80GB of storage
5. we want to connect to the network interface called br.test
6. we want to utilize the diskpool nvme
7. we will belong to the group, test_cluster. Which can be further configured later in kvm_vm_test_cluster.yml with specifics
8. we want to utilize the domain test.fiehnlab.ucdavis.edu for the name resolution
9. if this vm runs on a docker swarm manager, it can be a docker swarm manager as well, otherwise it will be a worker


####docker

This will define, which services you want to deploy by default and which network interface will be used
for advertising the manager ip. Please ensure you set this accordingly!

##kvm_vm.yml

during the installation of the KVM cluster, we will automatically generate inventory files for all possible
virtual clusters, which will all share the configuration provided in vm_node.yml

```.env
[all]
kvm-node-1-test-2x4 ansible_ssh_host=kvm-node-1-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-2-test-2x4 ansible_ssh_host=kvm-node-2-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-4-test-2x4 ansible_ssh_host=kvm-node-4-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-5-test-2x4 ansible_ssh_host=kvm-node-5-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-6-test-2x4 ansible_ssh_host=kvm-node-6-test-2x4.test.fiehnlab.ucdavis.edu

[kvm_vm]
kvm-node-1-test-2x4 ansible_ssh_host=kvm-node-1-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-2-test-2x4 ansible_ssh_host=kvm-node-2-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-4-test-2x4 ansible_ssh_host=kvm-node-4-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-5-test-2x4 ansible_ssh_host=kvm-node-5-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-6-test-2x4 ansible_ssh_host=kvm-node-6-test-2x4.test.fiehnlab.ucdavis.edu

[kvm_vm_test_cluster]
kvm-node-1-test-2x4 ansible_ssh_host=kvm-node-1-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-2-test-2x4 ansible_ssh_host=kvm-node-2-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-4-test-2x4 ansible_ssh_host=kvm-node-4-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-5-test-2x4 ansible_ssh_host=kvm-node-5-test-2x4.test.fiehnlab.ucdavis.edu
kvm-node-6-test-2x4 ansible_ssh_host=kvm-node-6-test-2x4.test.fiehnlab.ucdavis.edu

[docker_swarm_worker]
kvm-node-2-test-2x4
kvm-node-4-test-2x4
kvm-node-5-test-2x4
kvm-node-6-test-2x4


[docker_swarm_manager]
kvm-node-1-test-2x4
```

Would be an example for one of the generated inventory files files, in this case for a test cluster. It can be found in the root directory
under the name of

```.env
cluster-test_cluster.ini
```

And contains several different groups, which allow a fine grained configuration. Please be aware that you will need to adjust the playbooks for this to work, which we highly recommend anyway.

We are providing a default playbook, 'virtual_cluster.yml' as example how to get started

```

---
- hosts: all
  gather_facts: True
  become_user: root
  become: true

- hosts: kvm_vm
  tasks:
    - name: "configure user accounts"
      include_role:
        name: users
      vars:
        user: "{{kvm_user}}"
      loop: "{{accounts.users}}"
      loop_control:
        loop_var: "kvm_user"

    - import_role:
        name: network

    - import_role:
        name: default

    - import_role:
        name: docker

```


In this case all hosts in the section, 'kvm_vm' will be configured accordingly, which will be in each generated config file. For ease of use, we recommend you copy this file and change it like this:

```

---
- hosts: all
  gather_facts: True
  become_user: root
  become: true

- hosts: kvm_vm_test_cluster   <== this will now only apply for the hosts in this group
  tasks:
    - name: "configure user accounts"
      include_role:
        name: users
      vars:
        user: "{{kvm_user}}"
      loop: "{{accounts.users}}"
      loop_control:
        loop_var: "kvm_user"

    - import_role:
        name: network

    - import_role:
        name: default

    - import_role:
        name: docker
```

This now ensures that the file kvm_vm_test_cluster.yml and all it's settings will be honored and not cause conflicts with our decided configurations!