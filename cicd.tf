# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

resource "aws_security_group" "cicd" {
  name        = "allow_admin"
  description = "Allow admin via ssh"
  vpc_id      = "vpc-0603de69d0195f915"

  ingress {
    description = "SSH from Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "For admin"
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
    Name      = "cicd-sg",
    Terraform = "true"
  }
}
resource "aws_instance" "cicd" {
  ami           = "ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  #vpc_id = aws_vpc.vpc.id
  subnet_id              = "subnet-07568c2a575ee473c"
  vpc_security_group_ids = [aws_security_group.cicd.id]
  iam_instance_profile   = aws_iam_instance_profile.artifactory.name
  key_name               = aws_key_pair.demo.id
  user_data              = <<-EOF
              #!/bin/bash
              wget -O /etc/yum.repos.d/jenkins.repo \
              https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum update -y
              amazon-linux-extras install java-openjdk11
              yum install jenkins -y
              systemctl start jenkins
              EOF

  tags = {
    Name = "cicd"
  }
}


