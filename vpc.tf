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

// Criando subnets dinâmicas
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

// Criando Internet Gateway
resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

// Criando Route Table
resource "aws_route_table" "new-rtb" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0" // Todas subnets que forem colocadas dentro dessa Route Table terá acesso total a internet
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
}

// Associando Subnets na Route Table de forma dinâmica
resource "aws_route_table_association" "new-rtb-association" {
  count = 2
  route_table_id = aws_route_table.new-rtb.id
  subnet_id = aws_subnet.subnets.*.id[count.index]
}

// Criando subnet estática 1
#resource "aws_subnet" "new-subnet-1" {
#  availability_zone = "us-east-1a"
#  vpc_id = aws_vpc.new-vpc.id
#  cidr_block = "10.0.0.0/24"
#  tags = {
#    Name = "${var.prefix}-subnet-1"
#  }
#}

// Criando subnet estática 2
#resource "aws_subnet" "new-subnet-2" {
#  availability_zone = "us-east-1b"
#  vpc_id = aws_vpc.new-vpc.id
#  cidr_block = "10.0.1.0/24"
#  tags = {
#    Name = "${var.prefix}-subnet-2"
#  }
#}