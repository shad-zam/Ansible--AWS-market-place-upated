#!/bin/bash

set -ex

ANSIBLE_PLAYBOOK=~/auto-aws-image-update/playbooks/$1
ANSIBLE_BIN=/usr/bin/ansible-playbook
ANSIBLE_KEY= key_file
ANSIBLE_HOSTS= ~/auto-aws-image-update/Hosts

export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_HOST_KEY_CHECKING=false

${ANSIBLE_BIN}  \
  ${ANSIBLE_PLAYBOOK}  \
  --private-key ${ANSIBLE_KEY}    \
  --inventory-file ${ANSIBLE_HOSTS}
