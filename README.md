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

### Configuring roles with NFS mounts

For Docker services to function with nfs volumes, the mount point must be an existing and non-empty directory.  The `fiehnlab-utils/nfs-mount-init` role enables automatic configuration of these mount directories.

First add your volume using the nfs driver to your Docker stack (note that compose `version: '3.2'` or higher is required):

```yaml
version: '3.3'

volumes:
  nfs-data:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=${NFS_HOST},nolock,soft,rw"
      device: ":${NFS_PATH}"

services:
  test_service:
    image: hello-world
    volumes:
      - nfs-data:/path/to/volume/in/container
```

The import `fiehnlab-utils/nfs-mount-init` into your role's `tasks/main.yml` and define the `$NFS_HOST` and `$NFS_PATH` environmental variables when deploying your stack:

```yaml
- name: "configure nfs mount"
  include_role:
    name: fiehnlab-utils/nfs-mount-init

- name: "deploying Hello World"
  when:
    - "'docker_swarm_manager' in group_names"
  docker_stack:
    state: present
    name: hello-world
    compose: "docker-compose.yml"
  environment:
    NFS_HOST: "{{nfs.host}}"
    NFS_PATH: "/mnt/{{nfs_cluster}}/{{nfs_dir}}"
  tags:
    - deploy_mona
```

Finally, specify the `nfs.host`, `nfs_cluster`, and `nfs_dir` variables in either your role's defaults or in your playbook:

```yaml
    - import_role:
        name: fiehnlab/docker-registry
      vars:
        nfs:
          host: nas.example.com
        nfs_cluster: prod
        nfs_dir: hello-world
```

If you wish to utilize multiple mount points in your stack, you can set up multiple subdirectories in your `nfs_dir` by adding the `subdirectories` variable to your playbook or role vars:

```yaml
- name: "configure nfs mount"
  include_role:
    name: fiehnlab-utils/nfs-mount-init
  vars:
    subdirectories:
      - mount_A
      - mount_B
```
