setup.mac:
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform

terraform.ecs.plan: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} APP_NAME=talon-server bash scripts/tcl.sh -a plan )

terraform.ecs.apply: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} bash scripts/tcl.sh -a apply )
	chmod 400 tf-key-pair.pem

terraform.ecs.destroy: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} bash scripts/tcl.sh -a destroy )

terraform.ecs.show: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG} bash scripts/tcl.sh -a show )

sync.origin:
	git push origin main:master
	git push gitlab main:master
