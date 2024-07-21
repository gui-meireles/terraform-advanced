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

resource "aws_eks_node_group" "node-1" {
  cluster_name    = aws_eks_cluster.cluster.name // Pega o nome do cluster do arquivo cluster.tf
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.node.arn        // Atribui a role criada acima com todas as policies para o Node
  subnet_ids      = aws_subnet.subnets[*].id     // Adiciona as subnets que foram criadas no arquivo vpc.tf

  // Configurando Auto Scaling
  scaling_config {
    desired_size = var.desired_size // Tamanho desejado
    max_size     = var.max_size     // Tamanho máximo
    min_size     = var.min_size     // Tamanho mínimo
  }

  // Adiciona as dependências que o Node necessita para trabalhar
  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}