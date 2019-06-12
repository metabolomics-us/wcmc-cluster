#!/bin/bash

if [ -z "$1" ]
then
    ansible-playbook -K -i cluster-prod_cluster.ini --become vm_prod_cluster.yml
else
    ansible-playbook -K -i cluster-prod_cluster.ini --become "$1"    
fi
