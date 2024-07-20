// Criar vpc
resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

// Para imprimir no console todas as zonas disponíveis
data "aws_availability_zones" "available" {}
output "az" {
  value = "${data.aws_availability_zones.available.names}"
}

// Criar subnets dinâmicas
resource "aws_subnet" "subnets" {
  count = 2 // Quantidade de subnets que serão criadas
  availability_zone = data.aws_availability_zones.available.names[count.index] // AZ's dinâmicas de acordo com a quantidade de subnets acima
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true // _Todo recurso que for colocado dentro da subnet ele vai gerar um IP público automaticamente
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

// Criar subnet estática 1
#resource "aws_subnet" "new-subnet-1" {
#  availability_zone = "us-east-1a"
#  vpc_id = aws_vpc.new-vpc.id
#  cidr_block = "10.0.0.0/24"
#  tags = {
#    Name = "${var.prefix}-subnet-1"
#  }
#}

// Criar subnet estática 2
#resource "aws_subnet" "new-subnet-2" {
#  availability_zone = "us-east-1b"
#  vpc_id = aws_vpc.new-vpc.id
#  cidr_block = "10.0.1.0/24"
#  tags = {
#    Name = "${var.prefix}-subnet-2"
#  }
#}