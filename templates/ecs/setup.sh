#!/bin/bash
#
# Setup docker and ecs agent
#
sudo yum update -y
sudo amazon-linux-extras install -y ecs docker


echo ECS_CLUSTER=talon-api-cluster | sudo tee /etc/ecs/ecs.config
sudo service ecs start

sudo service docker start
sudo usermod -a -G docker ec2-user

sudo docker pull "${IMAGE}"
sudo docker run -p 9090:9090 -d "${IMAGE}"
