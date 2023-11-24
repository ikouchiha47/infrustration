## Infra things

This repository hosts the configuration code for infrastructure for mitil server

### Requirements:
- AWS account 
- AWS Cli
- Terraform Cli


### Pre requisites:

- Ensure you have created an IAM role with AdminPrivileges in AWS
- Encsure you have the proper credentials, AWS_ACCOUNT_ID and AWS_SECRET_KEY
- Ensure `aws configure` has been run and the region has been properly configured,
- Ensure you have the docker tag in ecr
- Ensure you have run `bash scripts/update-ecs-task-role.sh`



### Running:

- `cd <directory>`
- `AWS_ACCOUNT=<aws_account_id> DOCKER_BUILD_TAG=talon-server:<commit-hash> make terraform.ecs.apply`
- `AWS_ACCOUNT=<aws_account_id> DOCKER_BUILD_TAG=talon-server:<commit-hash> make terraform.ecs.destroy`




### Changelog:

#### 24th Nov. 2023
- Folder used `simpledeploy`
- ECR for docker container.
- AWS roles used are described in scripts/update-ecs-task-role
- Only EC2 instance is provisoned with public ip
