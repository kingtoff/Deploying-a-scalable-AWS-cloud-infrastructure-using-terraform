resource "aws_security_group" "cloudWebserverSecurityGroup" {
  name = "allow_ssh_hhtp"
  description = "Allow ssh http inbound traffic"
  vpc_id = var.cloud_vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
  
  tags = {
    Name = "cloudWebserverSecurityGroup"
    Project = "Demo"
  }
}

resource "aws_lb" "cloudLoadBalancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  subnets = [var.cloud_public_subnets[0].id, var.cloud_public_subnets[1].id]
  security_groups = [aws_security_group.cloudWebserverSecurityGroup.id]
  tags = {
    Name = "cloudLoadBalancer"
    Project = "Demo"
  }
}

resource "aws_lb_listener" "cloudLbListener" {
  load_balancer_arn = aws_lb.cloudLoadBalancer.arn

  port = 80
  protocol = "HTTP"
   
   default_action {
     target_group_arn = aws_lb_target_group.cloudTargetGroup.id
     type = "forward"
   }
}

resource "aws_lb_target_group" "cloudTargetGroup" {
  name = "toff-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.cloud_vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "TargetGroup"
    Project = "Demo"
  }
}


resource "aws_lb_target_group_attachment" "TOFFwebserver1" {
  target_group_arn = aws_lb_target_group.cloudTargetGroup.arn
  target_id = aws_instance.TOFFwebserver1.id
  port = 80
}


resource "aws_lb_target_group_attachment" "TOFFwebserver2" {
  target_group_arn = aws_lb_target_group.cloudTargetGroup.arn
  target_id = aws_instance.TOFFwebserver2.id
  port = 80
}

resource "aws_instance" "TOFFwebserver1" {
  ami = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = var.cloud_public_subnets[0].id
  security_groups = [ aws_security_group.cloudWebserverSecurityGroup.id]
  associate_public_ip_address = true
  
  user_data = <<-EOF
              #!/bin/bash -xe
              sudo su
              yum update -y
              yum install -y httpd
              echo "<h1>Hello, Fortune! you did a great job<h1>server: tfWebserver1" > /var/www/html/index.html
              echo "healthy" > /var/www/html/hc.html
              service httpd start
              EOF
}


resource "aws_instance" "TOFFwebserver2" {
  ami = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = var.cloud_public_subnets[0].id
  security_groups = [ aws_security_group.cloudWebserverSecurityGroup.id]
  associate_public_ip_address = true
  
  user_data = <<-EOF
              #!/bin/bash -xe
              sudo su
              yum update -y
              yum install -y httpd
              echo "<h1>Hello, Fortune! you did a great job<h1>server: tfWebserver2" > /var/www/html/index.html
              echo "healthy" > /var/www/html/hc.html
              service httpd start
              EOF
}

