setup.mac:
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform


terraform.ecs.apply: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} bash scripts/apply-terraform.sh )
	chmod 400 tf-key-pair

terraform.ecs.destroy: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} bash scripts/destroy-terraform.sh )
