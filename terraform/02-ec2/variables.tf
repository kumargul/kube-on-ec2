variable "environment" {
  description = "Name of the Environment"
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "control_plane_ingress_security_rules" {
  description = "Creates SecurityGroup for Control Plane"
  default     = []
}

variable "worker_node_ingress_security_rules" {
  description = "Create SecurityGroup for Worker Nodes"
}

variable "control_plane_instance_count" {
  description = "Map for number of Instances to be deployed as Control Planes"
}

variable "worker_nodes_instance_count" {
  description = "Map for number of Instances to be deployed as Control Planes"
}
