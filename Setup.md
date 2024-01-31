## Initial Setup

- [x] Create Ec2 instance with public ip
- [x] Create a security group to allow traffic to only 80 and 443 and 9090.
- [x] Use the templates/ecs/setup.sh to download the docker image and run it.
- [x] We can expose it like `-p 80:9090` or `-p 9090:9090`. The service will be accessible on the public_dns:port
- [x] EC2 instances will also need IAM roles to pull docker images(ECR) and some execution roles etc.


## Using ECS to manage and bootup ec2 instance

- [x] ECS needs availability zones, and for this it needs availability zone
- [x] For availability zone we need atleast two subnets
- [x] A load balancer will balance between these two subnets
- [x] ECS needs an [Auto Scaling Group](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-auto-scaling.html)
- [x] And since its an `ASG`, it will run a `EC2 cluster` using the `ECS`. Thats how shit works.
- [x] An ecs_service connects the `cluster` and `ecc task definition`


#### Routing

- [x] Create a VPC with a cidr_block
- [x] Create two subnet and associate with the vpc
- [x] Between the `internet` and `vpc` sits an internet gateway.We need an internet gateway and attach to the vpc.
- [x] To attach to the vpc we need to create a `routing table` to map ip ranges to the internet gateway
- [x] To make subnets receive traffic to and from internet, we add a routing association to the route table.
- [x] Create a LoadBalancer to balance the traffic between the two subnets.
- [x] The load balancer needs a target (and maybe a target listener) to accept request to the port on which the ec2 server is running
- [x] Since these subnets are attached to the internet gateway, the ports are protected by security groups. (like firewall)
- [x] The load balancer target is also attached to the same vpc.
- [x] __The ASG is connected to the ALB using ALB Target Group ARN__
- [x] Create ecs task and launch template 


### Links:

- https://www.architect.io/blog/2021-03-30/create-and-manage-an-aws-ecs-cluster-with-terraform/
- https://medium.com/swlh/creating-an-aws-ecs-cluster-of-ec2-instances-with-terraform-85a10b5cfbe3
- https://medium.com/geekculture/how-to-manage-auto-scaling-group-and-load-balancer-with-terraform-9ece263060b5
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-auto-scaling.html
- https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/tutorial-ec2-auto-scaling-load-balancer.html

