resource "aws_db_subnet_group" "Cloud-DBSubnetGroup" {
  name = "cloud-db-subnet-group"
  subnet_ids = [
    var.cloud_private_subnets[0].id,
    var.cloud_private_subnets[1].id
  ]
  tags = {
    Name = "cloudDBSubnetGroup"
    Project = "Demo"
  }
}

resource "aws_security_group" "cloudDBSecurityGroup" {
  name = "cloud-db-security-group"
  vpc_id = var.cloud_vpc_id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
        var.cloud_private_subnet_cidrs[0],
        var.cloud_private_subnet_cidrs[1]
    ]
  }
  tags = {
    Name = "cloudDBSecurityGroup"
    Project = "Demo"
  }
}

resource "aws_db_instance" "cloudRDS" {
  availability_zone = var.db_az
  db_subnet_group_name = aws_db_subnet_group.Cloud-DBSubnetGroup.name
  vpc_security_group_ids = [ aws_security_group.cloudDBSecurityGroup.id]
  allocated_storage = 20
  storage_type = "standard"
  engine = "postgres"
  engine_version = "12"
  instance_class = "db.t2.micro"
  name = var.db_name
  username = var.db_user_name
  password = var.db_user_password
  skip_final_snapshot = true
  tags = {
    Name = "cloudRDS"
    Project = "Demo"
  }
}
