#!/bin/bash

if [ -z "$1" ]
then
    ansible-playbook -K -i cluster-dev_cluster.ini --become vm_dev_cluster.yml
else
    ansible-playbook -K -i cluster-dev_cluster.ini --become "$1"    
fi
