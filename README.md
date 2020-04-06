# apicterra

## Basic aws eks cluster construction with terraform.  
Focus on the eks building blocks.  
Variables are kept to a mimimum.  
Configurations use explicit dependencies.  
No data source objects are used.  

For more advanced way to create eks cluster look at the terraform aws eks module.  

*Cluster construction sequence:*  

Vpc, iam, security groups, eks cluster, key pairs, node groups, container registry, bastion host.  

**Applying terraform.**  
Clone repository to a directory.  
`terraform init`  

Update *terraform.tfvars* variable values.  

Terraform work loop: `terraform validate`, `terraform plan`, `terraform apply`  

**Required permissions.**  
An iam user that runs terraform must have vpc and eks permissions.  

effect: Allow, action: ec2:*, resrouce: *  
effect: Allow, action: eks:*, resource: *  

**Variables (terraform.tfvars, variables.tf)**  
You must set the values of the variables in the terraform.tfvars file.
Look at the *variables.tf* for variable declarations.  

Note that values for the *eks_region* and *eks_availability_zones* variables are related.  

**Vpc module (vpc.tf)**  
Vpc is defined with public and private subnets.  
Public subnets are used for load balancers, private subnets for worker nodes.  

Each private subnet is configured with the nat gateway.  
Worker nodes deployed to the private subnets must have outboud internet access.  

Subnets are tagged as required by the eks.  
Public subnets are tagged for the external load balaner.  
Private subnets are tagged for the internal load balancer.  

Ingress controller helm chart that creates load balancer  
has special annotation where to place a load balancer.

**Iam roles (iam.tf).**  
Iam cluster role is required to allow eks service to create resources in the vpc.
For example elastic network interface must be created in the vpc for the vpc to control plane communication.  

Iam node role is requied to allow worker nodes to make kubernetes api calls.
For example kubelet running on each worker node must be able to call kubernetes api server.  

In addition, container registry read-only managed policy is attached to the node role to allow docker image pull from the docker registry.  

**Security group module (sec-groups.tf).**  
Cluster security group is attached to the elastic network interfaces to allow vpc to eks control plane communication.  

Node security group allows inbound ssh access to the worker nodes.  

**Eks cluster resource (eks-cluster.tf)**  
Kubernetes version is set to 1.15  

Vpc is configured to enable public access to the kubernetes api server.  
Private access to the kubernetes api server is disabled.  

**Eks worker node key pair (ec2-key.tf).**  
Terraform aws_key_pair resource requires existing public key.  

create key pair with the *ssh-keygen*  

**import key-pair**  
aws ec2 import-key-pair --key-name="apic" ...  

update eks_node_ssh_key variable variables.tf with the key name.  
paste public key into *ec2-key.tf*  

**Eks nodegroup (eks-nodegroup.tf).**  
Nodegroup is autoscaling group. Worker nodes are deployed into auto-scaling group.  

There are 2 types of node groups: managed node groups and self-managed node groups.  
Both types of node groups provide the same functionality.  

Managed node groups automate worker node provisioning and management. Self-managed node group require low-level configuration and additional steps to join a cluster.  

We use aws_eks_node_group resource to configure managed node group.  

Important paramaters for this configuration are instance_type and scaling_config.  

Both of these parameters are driven by application requirements.  

You can define more restirive rules for ssh access to the worker nodes.  

**Container registry.**  
Container registry is available in aws account.  
To upload images into container registry follow aws documentation how to create access token, create repository and push container image into repository.  

Kubelet on the worker node is granted registry read-only managed permission by the node role. (see iam section) and can pull images from the registry.  

**Bastion host.**  
Depending on the aws vpc setup bastion host may be required.  

Bastion host can be created as an ordinary ec2 instance.  
It is also possible to create bastion host within autoscaling group.  

If you create bastion host make sure you put it on the public subnet in the eks vpc.  
Create security group to allow inbound ssh into the bastion host.  
