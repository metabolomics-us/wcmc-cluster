#!/bin/bash

if [ -z "$1" ]
then
    ansible-playbook -vvv -K -i cluster-database.ini --become vm_database.yml
else
    ansible-playbook -vvv -K -i cluster-database.ini --become "$1"
fi
