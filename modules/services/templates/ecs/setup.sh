#!/bin/bash
#
# Setup docker and ecs agent
#
sudo yum update -y
# sudo amazon-linux-extras install -y ecs docker


# echo ECS_CLUSTER=talon-api-cluster | sudo tee /etc/ecs/ecs.config
# sudo service ecs start

# sudo service docker start
# sudo usermod -a -G docker ec2-user

echo "sudo docker pull ${IMAGE}" | sudo tee /etc/docker_cmd.log

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin "${AWS_ACCOUNT}.dkr.ecr.ap-south-1.amazonaws.com"
sudo docker pull "${IMAGE}"
sudo docker run -p 80:9090 -d "${IMAGE}"
