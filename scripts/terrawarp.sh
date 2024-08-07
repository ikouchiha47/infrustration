#!/bin/bash
# This is a wrapper around terraform to run commands with
# project specific config
#
# to use this, first call
# source ./scripts/terrawrapper.sh load-env <env-file>
# ./scripts/terrwrapper <terraform commands>
#
export AWS_PROFILE="mitil"

function set_envfile() {
  if [[ -z "$1" ]]; then
    echo "env file name not provided"
  fi

  echo "$1"
  export _TF_ENVFILE="$1"
}

function aws_account_id() {
  if [[ ! -z "${AWS_ACCOUNT_ID}" ]]; then
    echo "${AWS_ACCOUNT_ID} aws account id already set"
  else
    value=$(aws sts \
      get-caller-identity \
      --query "Account" \
      --output text \
      --profile="${AWS_PROFILE}"\
    )
        export AWS_ACCOUNT_ID="${value}"
  fi
}

function load_env() {
  file="${_TF_ENVFILE}"

  if [[ ! -f "$file" ]]; then
    echo "_TF_ENVFILE variable needs to be set"
    exit 1
  fi

  # echo "laoding from $file"

  declare -a env_vars

  while IFS= read -r line; do
    exported_var=$(echo "$line" | envsubst)
    # echo "Exported Variable: $exported_var"
    env_vars+=("$exported_var")
  done < <(grep -v '^#' "$file")

  export "${env_vars[@]}"
  
  # echo "profile $TF_VAR_AWS_PROFILE"
  # echo "app name $TF_VAR_APP_NAME" 
  # echo "env values exported"
}

if [[ "$1" == "load-env" ]]; then
  echo "setting env file"
  set_envfile "$2"
  echo "ENVFILE set to ${_TF_ENVFILE}"
elif [[ "$1" == "get-env" ]]; then
  echo "ENVFILE set to ${_TF_ENVFILE}"
else
  aws_account_id
  load_env

  if [[ -z "$TF_VAR_AWS_ACCOUNT" || -z "$TF_VAR_APP_NAME" ]]; then
      echo "env values not exported"
      exit 1
  fi

  terraform "$@"
fi
