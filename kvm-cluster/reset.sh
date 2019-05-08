ansible-playbook -i wcmc.inventory --become --ask-become-pass kvm_cluster.yml --tags drop_kvm,destroy_swarm
