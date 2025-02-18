terraform {
  backend "s3" {}
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      env   = var.environment
      owner = "testingGK"
    }
  }
}

locals {
  control_plane_sgs = concat(
    [aws_security_group.control_plane.id],
    tolist(data.aws_security_groups.smc_provided_sg_ids.ids)
  )
  worker_nodes_sgs = concat(
    [aws_security_group.worker_nodes.id],
    tolist(data.aws_security_groups.smc_provided_sg_ids.ids)
  )
}

# SecurityGroup Control Plane
resource "aws_security_group" "control_plane" {
  name        = "testingGK-ControlPlane"
  description = "testing GK - SecurityGroup for ControlPlane"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "cp_ingress_security_group_rules" {
  count             = length(var.control_plane_ingress_security_rules)
  cidr_blocks       = var.control_plane_ingress_security_rules[count.index].cidr_blocks
  prefix_list_ids   = length(var.control_plane_ingress_security_rules[count.index].prefix_list_ids) > 0 ? var.control_plane_ingress_security_rules[count.index].prefix_list_ids : []
  description       = var.control_plane_ingress_security_rules[count.index].description
  from_port         = var.control_plane_ingress_security_rules[count.index].from_port
  protocol          = var.control_plane_ingress_security_rules[count.index].protocol
  security_group_id = aws_security_group.control_plane.id
  to_port           = var.control_plane_ingress_security_rules[count.index].to_port
  type              = "ingress"
}

resource "aws_security_group_rule" "cp_egress_security_group_rules" {
  cidr_blocks       = ["0.0.0.0/0"]
  prefix_list_ids   = []
  description       = "Allow all traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.control_plane.id
  to_port           = 0
  type              = "egress"
}

# SecurityGroup Worker nodes
resource "aws_security_group" "worker_nodes" {
  name        = "testingGK-WorkerNodes"
  description = "testing GK - SecurityGroup for WorkerNodes"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "worker_nodes_ingress_security_group_rules" {
  count             = length(var.worker_node_ingress_security_rules)
  cidr_blocks       = var.worker_node_ingress_security_rules[count.index].cidr_blocks
  prefix_list_ids   = length(var.worker_node_ingress_security_rules[count.index].prefix_list_ids) > 0 ? var.worker_node_ingress_security_rules[count.index].prefix_list_ids : []
  description       = var.worker_node_ingress_security_rules[count.index].description
  from_port         = var.worker_node_ingress_security_rules[count.index].from_port
  protocol          = var.worker_node_ingress_security_rules[count.index].protocol
  security_group_id = aws_security_group.worker_nodes.id
  to_port           = var.worker_node_ingress_security_rules[count.index].to_port
  type              = "ingress"
}

resource "aws_security_group_rule" "wn_egress_security_group_rules" {
  cidr_blocks       = ["0.0.0.0/0"]
  prefix_list_ids   = []
  description       = "Allow all traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker_nodes.id
  to_port           = 0
  type              = "egress"
}
