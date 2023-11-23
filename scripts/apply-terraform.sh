#!/bin/bash
#
# invoking terraform apply with env values

echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform init

TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform plan -out=tfplan

TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
  terraform apply "tfplan"
