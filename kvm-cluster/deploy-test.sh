#!/bin/bash

if [ -z "$1" ]
then
    ansible-playbook -K -i cluster-test_cluster.ini --become vm_test_cluster.yml
else
    ansible-playbook -K -i cluster-test_cluster.ini --become "$1"    
fi
