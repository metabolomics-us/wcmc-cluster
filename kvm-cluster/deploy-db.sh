#!/bin/bash

if [ -z "$1" ]
then
    ansible-playbook -K -i cluster-database.ini --become vm_database.yml
else
    ansible-playbook -K -i cluster-database.ini --become "$1"
fi
