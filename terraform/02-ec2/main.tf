resource "aws_instance" "control_plane" {
  for_each             = var.control_plane_instance_count
  ami                  = each.value["ami_id"]
  availability_zone    = each.value["az"]
  instance_type        = each.value["instance_type"]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  network_interface {
    network_interface_id = aws_network_interface.control_plane[each.key].id
    device_index         = 0
  }

  user_data = templatefile(
    "${path.module}/control-plane-userdata.sh.tpl", {
      root_ca = base64encode(data.aws_secretsmanager_secret_version.rootca.secret_string)
    })
  
  root_block_device {
    volume_type = "gp3"
    volume_size = "100"
    encrypted   = true
  }
  tags = {
    Name = "${each.key}-testingGK"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
  lifecycle {
    ignore_changes = [user_data]
  }
  disable_api_termination = true
}

