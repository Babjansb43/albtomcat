resource "aws_security_group" "alb" {
  name        = "allow enduser"
  description = "Allow enduser inbound traffic"
  vpc_id      = "vpc-0603de69d0195f915"

  ingress {
    description = "enduser for admin"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name        = "Alb-sg"
}
}


# alb 

resource "aws_lb" "alb" {
  name               = "Tomcat-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = ["subnet-07568c2a575ee473c", "subnet-0a08176b9903998f7"]

  enable_deletion_protection = true

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
      Name        = "Alb-Tomcat"
    }
}

#tg 
resource "aws_lb_target_group" "http" {
  name     = "http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0603de69d0195f915"

  health_check {
    path                = "/54.254.194.167:8080/sparkjava-hello-world-17/hello"
    port                = 8080
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200" # has to be HTTP 200 or fails
  }
}

#listener 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group_attachment" "http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.tomcat.id
  port             = 8080
}