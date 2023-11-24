#!/bin/bash
#
# Apply ecs task definition
#
VERSION=$(git rev-parse --short HEAD)
DOCKER_BUILD_TAG="talon-server:${VERSION}"

IMAGE=${DOCKER_BUILD_TAG} AWS_ACCOUNT=${AWS_ACCOUNT} envsubst < "./infrafiles/ecs/task-definition.json" > "./infrafiles/ecs/task-definition.temp.json"

aws ecs register-task-definition --cli-input-json file://./infrafiles/ecs/task-definition.temp.json
