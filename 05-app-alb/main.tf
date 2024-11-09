resource "aws_lb" "app-alb" {
  name               = "${local.name}-${var.tags.Component}"
  internal           = true #because we use internal not outside
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  #enable_deletion_protection = true # because we delete after practice

  tags = merge(
    var.common_tags,
    var.tags

  )
    
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, this response is from app ALB"
      status_code  = "200"
    }
  }
}