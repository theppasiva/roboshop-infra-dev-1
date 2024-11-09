# create catalogue target group
resource "aws_lb_target_group" "catalogue" {
  name     = "${local.name}-${var.tags.Component}" #roboshop-dev-catalogue
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
      healthy_threshold   = 2
      interval            = 10
      unhealthy_threshold = 3
      timeout             = 5
      path                = "/health"
      port                = 8080
      matcher             = "200-299" #matcher is nothing but success codes from 200-299
  }
}
# create cataloue instance
module "catalogue" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.name}-${var.tags.Component}-ami"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
  subnet_id              = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
  iam_instance_profile   = "Ec2roleForShellSript"
  tags = merge(
    var.common_tags,
    var.tags
  )
}
# provision with ansible
resource "null_resource" "catalogue" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.catalogue.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.catalogue.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}
# terraform aws stop instance
resource "aws_ec2_instance_state" "cataloue" {
  instance_id = module.catalogue.id
  state       = "stopped"
  depends_on = [null_resource.catalogue] # we must define depends_on other wise it will stopped at the time of creation
}
# get ami from instance
resource "aws_ami_from_instance" "cataloue" {
  name               = "${local.name}-${var.tags.Component}-${local.current_time}"
  source_instance_id = "module.catalogue.id"
}

# destroy instance after ami creation
resource "null_resource" "catalogue_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = aws_ami_from_instance.cataloue.id
  }

  provisioner "local_exec" {
    command      = "aws ec2 terminate-instances --instance-ids ${module.catalogue.id}"
    destination = "/tmp/bootstrap.sh"
  }

  depends_on = [aws_ami_from_instance.cataloue]
}
