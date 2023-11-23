#!/bin/bash
#
# get the output of ec2 alb

TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform refresh

TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform output alb_dns_name

TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform output public_ip_server_subnet1

# terraform output public_ip_server_subnet2
