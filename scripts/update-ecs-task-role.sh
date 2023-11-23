#!/bin/bash
#
# Creates a new taskExecution role for ecs service task
#
aws iam create-role \
      --role-name ecsTaskExecutionRole \
      --assume-role-policy-document file://./infrafiles/ecs/ecs_execution_role.json

aws iam attach-role-policy \
      --role-name ecsEcrTaskExecutionRole  \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

aws iam attach-role-policy \
      --role-name ecsEcrTaskExecutionRole \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
