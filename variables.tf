variable "eks_region" {
   description = "eks cluster region"
}

variable "eks_availability_zones" {
   description = "availability zones for the eks cluster"
   type = list
}

variable "eks_vpc" {
   description = "eks vpc name"
}

variable "eks_cluster" {
   description = "eks cluster name"
}

variable "eks_node_ssh_key" {
   description = "eks worker node ssh key"
}
