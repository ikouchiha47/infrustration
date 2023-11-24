#!/bin/bash
#
#
TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform destroy
