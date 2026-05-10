module "vpc" {
  source      = "./modules/aws_vpc"
  vpc_name    = "k8s-vpc"
  vpc_cidr    = "10.0.0.0/16"
  subnet_name = "public-subnet"
  subnet_cidr = "10.0.1.0/24"
  igw_name     = "k8s-igw"
}

module "security_group" {
  source = "./modules/aws_sg"
  vpc_id = module.vpc.vpc_id
  sg_name = "k8s-sg"
}

module "key_pair" {
  source = "./modules/key-pair"
  key_name = "k8s-key"
}
module "master" {
  source = "./modules/aws_vms"
  instance_name = "k8s-master"
  instance_type = "c7i-flex.large"
  subnet_id              = module.vpc.subnet_id
  security_group_id      = module.security_group.sg_id
  key_name = module.key_pair.key_name
  user_data = file("./userdata/master.sh")
}

module "worker" {
  source = "./modules/aws_vms"
  instance_name = "k8s-worker"
  instance_type = "c7i-flex.large"
  subnet_id              = module.vpc.subnet_id
  security_group_id      = module.security_group.sg_id
  key_name = module.key_pair.key_name
  user_data = file("./userdata/worker.sh")
}