resource "aws_db_subnet_group" "mysql-subnet" {
  name        = "mysql-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.main-private-1.id, aws_subnet.main-private-2.id]
}

resource "aws_db_parameter_group" "mysql-parameters" {
  name        = "mysql-params"
  family      = "mysql8.0"
  description = "mysql parameter group"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage         = 20 # 100 GB of storage, gives us more IOPS than a lower number
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t2.micro" # use micro if you want to use the free tier
  identifier                = "mysql"
  db_name                   = "mydatabase"     # database name
  username                  = "root"           # username
  password                  = var.RDS_PASSWORD # password
  db_subnet_group_name      = aws_db_subnet_group.mysql-subnet.name
  parameter_group_name      = aws_db_parameter_group.mysql-parameters.name
  multi_az                  = "false" # set to true to have high availability: 2 instances synchronized with each other
  vpc_security_group_ids    = [aws_security_group.allow-mysql.id]
  storage_type              = "gp2"
  backup_retention_period   = 1                                           # how long you’re going to keep your backups
  availability_zone         = aws_subnet.main-private-1.availability_zone # prefered AZ
  final_snapshot_identifier = "mysql-final-snapshot"                      # final snapshot when executing terraform destroy
  tags = {
    Name = "mysql-instance"
  }
}

