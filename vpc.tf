// Criar vpc
resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "fullcycle-vpc"
  }
}

// Para imprimir no console todas as zonas disponíveis
data "aws_availability_zones" "available" {}
output "az" {
  value = "${data.aws_availability_zones.available.names}"
}

// Criar subnet
resource "aws_subnet" "new-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "fullcycle-subnet-1"
  }
}

// Criar subnet 2
resource "aws_subnet" "new-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "fullcycle-subnet-2"
  }
}