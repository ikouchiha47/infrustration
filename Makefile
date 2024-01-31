setup.mac:
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform

terraform.ecs.plan: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} APP_NAME=talon-server bash scripts/tcl.sh -a plan )

terraform.ecs.apply: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} bash scripts/tcl.sh -a apply )
	chmod 400 tf-key-pair.pem

terraform.ecs.destroy: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} bash scripts/tcl.sh -a destroy )

terraform.ecs.show: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} bash scripts/tcl.sh -a show )

terraform.svc.plan: 
	( cd modules/services && \
		BACK_CFG=./talon.hcl \
		AWS_ACCOUNT=${AWS_ACCOUNT} \
		AWS_PROFILE=${AWS_PROFILE} APP_NAME=talon-server bash ../../scripts/tcl.sh -a plan )

terraform.svc.apply: 
	( cd modules/services && \
		BACK_CFG=./talon.hcl \
		AWS_ACCOUNT=${AWS_ACCOUNT} \
		AWS_PROFILE=${AWS_PROFILE} APP_NAME=talon-server bash ../../scripts/tcl.sh -a apply )

sync.origin:
	git push origin main:master
	git push gitlab main:master
