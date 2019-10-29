#!/usr/bin/env bash
ansible-playbook -i wcmc.inventory --become --ask-become-pass --ask-pass barebone.yml --user $1
