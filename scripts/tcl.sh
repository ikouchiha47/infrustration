#!/bin/bash
#
# Wrapper over terraform commands and helpers
#
#
function plan() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform validate

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform plan --target=module.services
}

function apply() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform validate

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform plan --target=module.services

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform apply
}


function destroy() {
  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform destroy
}


function show() {
  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform show
}

__ACTIONS__=":apply:show:destroy:plan:"
ACTION="show"

usage() { echo "Usage: $0 [-a <show|apply|destroy|plan>]" 1>&2; exit 1; }

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
elif [[ "$ACTION" == "plan" ]]; then
  plan
elif [[ "$ACTION" == "apply" ]]; then
  apply
elif [[ "$ACTION" == "destroy" ]]; then
  destroy
fi
