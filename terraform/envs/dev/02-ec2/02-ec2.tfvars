environment = "dev"
vpc_id = "vpc-0e90e8a7c557d16d5"

control_plane_instance_count = {
  control_plane_1 = {
    ami_id = "ami-0880a9d3e47ca9ff6" #Ubuntu 20
    instance_type = "t2.large"
    subnet = "subnet-0afcfe6943b147e34"
    private_ip = "10.134.116.120"
  },
  # control_plane_2 = {
  #   subnet = "subnet-0afcfe6943b147e34"
  #   private_ip = "10.134.116.121"
  # },
}

worker_nodes_instance_count = {
  worker1 = {
    ami_id = "ami-0880a9d3e47ca9ff6" #Ubuntu 20
    instance_type = "t2.large"
    subnet = "subnet-0afcfe6943b147e34"
    private_ip = "10.134.116.122"
  },
  worker2 = {
    ami_id = "ami-0880a9d3e47ca9ff6" #Ubuntu 20
    instance_type = "t2.large"
    subnet = "subnet-0afcfe6943b147e34"
    private_ip = "10.134.116.123"
  },
}

control_plane_ingress_security_rules = [
  {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
  {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
  {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
  {
    description = "Kube Scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
  {
    description = "Kuber controller manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
]
worker_node_ingress_security_rules = [
  {
    description = "Kublet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
  {
    description = "Kublet API"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
    prefix_list_ids = []
  },
]