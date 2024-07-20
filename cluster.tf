resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.new-vpc.id

  // Vamos utilizar o egress para permitir que nosso Cluster tenha acesso a toda a internet
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-sg"
  }
}