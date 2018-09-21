#!/bin/bash

`dirname $0`/ec2.py | jq '._meta.hostvars | with_entries( .value |= with_entries(select(.key == "ansible_host")))'
