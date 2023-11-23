#!/bin/bash
#
# generate keys for ec2 instance
#
aws ec2 create-key-pair \
    --key-name ecs_my_user \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > ecs_my_user.pem
