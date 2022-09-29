resource "aws_security_group" "tomcatsg" {
  name        = "allow_tomcat"
  description = "Allow tomcat inbound traffic"
  vpc_id      = "vpc-0603de69d0195f915"

  ingress {
    description = "SSH from Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP/HTTPS Access"
    from_port   = 8080
    to_port     = 8080
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
    Name      = "tomcat-sg",
    Terraform = "true"
  }
}
resource "aws_instance" "tomcat" {
  ami           = "ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  #vpc_id = aws_vpc.vpc.id
  subnet_id              = "subnet-0a08176b9903998f7"
  vpc_security_group_ids = [aws_security_group.tomcatsg.id]
  key_name               = aws_key_pair.demo.id

  tags = {
    Name = "tomcat"
  }
}
