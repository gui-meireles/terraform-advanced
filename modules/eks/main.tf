// Início do Cluster
resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id

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

// Criando role para dar permissoes ao cluster criar um serviço EKS
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
    subnet_ids = var.subnet_ids                     // Adiciona as subnets que foram criadas no arquivo vpc.tf
    security_group_ids = [aws_security_group.sg.id] // Adiciona o security group que permite o acesso total do Cluster na internet
  }

  // Adiciona as dependências que o Cluster necessita para trabalhar
  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
  ]
}

// Fim do Cluster
// Início do Node

// Criando role para dar permissoes ao node para criar maquinas EC2
resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

// Criando Node Group com instâncias t2.micro
resource "aws_eks_node_group" "node-1" {
  cluster_name    = aws_eks_cluster.cluster.name // Pega o nome do cluster do arquivo cluster.tf
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.node.arn        // Atribui a role criada acima com todas as policies para o Node
  subnet_ids      = var.subnet_ids               // Adiciona as subnets que foram criadas no arquivo vpc.tf

  // Configurando Auto Scaling
  scaling_config {
    desired_size = var.desired_size // Tamanho desejado
    max_size     = var.max_size     // Tamanho máximo
    min_size     = var.min_size     // Tamanho mínimo
  }

  instance_types = ["t2.micro"] // Veja qual instância EC2 está como FREE TIER

  // Adiciona as dependências que o Node necessita para trabalhar
  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

// Fim do Node