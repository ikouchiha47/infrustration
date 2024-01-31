#!/bin/bash
#
# Wrapper over terraform commands and helpers
#
#
BACKEND_CONFIG="${BACK_CFG:-./infra.hcl}"

function plan() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

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
    terraform plan
}

function apply() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

  # TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  #   TF_VAR_AWS_REGION="ap-south-1" \
  #   TF_VAR_PARAM_PREFIX="talon/apiserver" \
  #   TF_VAR_ENVIRONMENT="prod" \
  #   TF_VAR_APP_NAME="${APP_NAME}" \
  #   TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
  #   terraform validate

  # TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  #   TF_VAR_AWS_REGION="ap-south-1" \
  #   TF_VAR_PARAM_PREFIX="talon/apiserver" \
  #   TF_VAR_ENVIRONMENT="prod" \
  #   TF_VAR_APP_NAME="${APP_NAME}" \
  #   TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
  #   terraform plan

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform apply
}


function destroy() {
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform destroy
}


function show() {
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform show
}

function plan_svc() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform -chdir=./modules/services init \
    -backend-config="./talon.hcl"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform -chdir=./modules/services validate

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    terraform -chdir=./modules/services plan
}

__ACTIONS__=":apply:show:destroy:plan:plan_svc:"
ACTION="show"

usage() { echo "Usage: $0 [-a <show|apply|destroy|plan|plan_svc>]" 1>&2; exit 1; }

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
elif [[ "$ACTION" == "plan_svc" ]]; then
  plan_svc
elif [[ "$ACTION" == "apply" ]]; then
  apply
elif [[ "$ACTION" == "destroy" ]]; then
  destroy
fi
