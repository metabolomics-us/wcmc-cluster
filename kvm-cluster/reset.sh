ansible-playbook -i wcmc.inventory --become --ask-become-pass kvm_cluster.yml --tags destroy_swarm,drop_kvm
