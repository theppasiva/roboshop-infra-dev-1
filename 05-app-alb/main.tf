resource "aws_lb" "app-alb" {
  name               = "${local.name}-${var.tags.Component}"
  internal           = true #because we use internal not outside
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  }

  tags = merge(
    var.common_tags,
    var.tags

  )
    
}