#!/bin/bash
#
# Wrapper over terraform commands and helpers
#
#
function apply() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  terraform init

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
    terraform validate

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
    terraform plan

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
    terraform apply
}


function destroy() {
  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
    terraform destroy
}


function show() {
  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_DOCKER_IMAGE="${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com/${DOCKER_BUILD_TAG}" \
    terraform show
}

__ACTIONS__=":apply:show:destroy:"
ACTION="show"

usage() { echo "Usage: $0 [-a <show|apply|destroy>]" 1>&2; exit 1; }

while getopts ":a:" arg; do
  case "${arg}" in
    a)
      ACTION="${OPTARG}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ ! "${__ACTIONS__}" =~ ":${ACTION}:" ]]; then
  echo "invalid actions"
  usage
  exit 1
fi

echo "Running terraform ${ACTION}"
if [[ "$ACTION" == "show" ]]; then
  show
elif [[ "$ACTION" == "apply" ]]; then
  apply
elif [[ "$ACTION" == "destroy" ]]; then
  destroy
fi
