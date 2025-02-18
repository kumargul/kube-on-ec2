resource "aws_network_interface" "control_plane" {
  for_each        = var.control_plane_instance_count
  subnet_id       = each.value["subnet"]
  security_groups = local.control_plane_sgs
  private_ips     = [each.value["private_ip"]]
  tags = {
    Environment = var.environment
    Name        = "testingGK-${var.environment}-${each.key}"
  }
}

resource "aws_network_interface" "worker_nodes" {
  for_each        = var.worker_nodes_instance_count
  subnet_id       = each.value["subnet"]
  security_groups = local.worker_nodes_sgs
  private_ips     = [each.value["private_ip"]]
  tags = {
    Environment = var.environment
    Name        = "testingGK-${var.environment}-${each.key}"
  }
}
