provider "aws" {
  region  = "${var.region}"
  profile = "devops-svc"
}

data "aws_subnet_ids" "example" {
  vpc_id = "${var.vpc_id}"
}

data "aws_subnet" "example" {
  count = "${length(data.aws_subnet_ids.example.ids)}"
  id    = "${data.aws_subnet_ids.example.ids[count.index]}"
}

module "kubernetes-server" {
  source        = "./kubernetes-server"
  instance_type = "${var.instance_type}"
  instance_ami  = "${var.instance-ami}"
  server-name   = "${var.server-name}"
  instance_key  = "${var.key}"
  vpc_id        = "${var.vpc_id}"
  k8-subnet     = "${data.aws_subnet_ids.example.ids[0]}"
  cluster-name  = "${var.cluster-name}"
  billto        = "${var.billto}"
}

module "eks" {
  source                        = "./cluster"
  vpc_id                        = "${var.vpc_id}"
  instance_type                 = "${var.instance_type}"
  cluster-name                  = "${var.cluster-name}"
  kubernetes-server-instance-sg = "${module.kubernetes-server.kubernetes-server-instance-sg}"
  eks_subnets                   = ["${data.aws_subnet_ids.example.ids}"]
  worker_subnet                 = ["${data.aws_subnet_ids.example.ids}"]
  subnet_ids                    = ["${data.aws_subnet_ids.example.ids}"]
  cluster-name                  = "${var.cluster-name}"
  billto                        = "${var.billto}"
}
