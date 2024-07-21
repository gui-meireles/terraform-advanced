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

// Criando role
resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Adicionando policy
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

// Adicionando policy
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

// Criando recurso de watch para salvar logs do Cluster
resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}

// Criando Cluster EKS
resource "aws_eks_cluster" "cluster" {
  name     = "${var.prefix}-${var.cluster_name}" // Nome do Cluster
  role_arn = aws_iam_role.cluster.arn            // Atribui a role criada acima com todas as policies para o Cluster
  enabled_cluster_log_types = ["api", "audit"]   // Tipos de logs para salvar

  vpc_config {
    subnet_ids = aws_subnet.subnets[*].id           // Adiciona todas as subnets que foram criadas acima
    security_group_ids = [aws_security_group.sg.id] // Adiciona o security group que permite o acesso total do Cluster na internet
  }

  // Adiciona as dependências que o Cluster necessita para trabalhar
  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
  ]
}