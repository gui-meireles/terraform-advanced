# Terraform avançado

## Conceitos de VPC na AWS

O conceito de **VPC** (Virtual Private Cloud) é uma **rede virtual na nuvem** que permite que você **crie recursos de computação,**
**armazenamento** e **rede** de _**forma isolada**_ e segura dentro do ambiente da AWS.

Através do VPC, é possível **definir sub-redes**, **tabelas de roteamento**, **gateways de internet** e regras de segurança para
controlar o tráfego de entrada e saída dos recursos hospedados na nuvem.

>**Para entender mais sobre VPC e console AWS**, veja o módulo `Criando cluster Kubernetes` no curso
de **Terraform** do Full Cycle.

---

### Configuração inicial da AWS

Crie um usuário **admin** e uma **chave de acesso**.

Baixe o **AWS CLI** e digite no terminal: `aws configure` e informe a chave de acesso. (Utilize a região: `us-east-1`)

### *Importante:

Saiba que ao criar um `EKS ou EC2` na AWS vai te **gerar custos**, caso queira criar, **lembre-se sempre de excluí-los**
para não gerar custos adicionais, para isso basta comentar todos os resources relacionados ao `EKS e EC2` e verificar no
**console da AWS**.

---

### Criando VPC

Vamos criar uma **VPC com o Terraform**, mas antes, precisamos adicionar o provider da AWS no Terraform, para isso
utilizaremos o arquivo `providers.tf`.

Para rodá-lo, utilize o comando: `terraform init`.

No arquivo `vpc.tf` vamos criar a configuração da VPC.

> Para saber mais sobre a documentação do provider da AWS, abra: https://registry.terraform.io/providers/hashicorp/aws

Com o arquivo `vpc.tf` criado, vamos executar os comandos: `terraform plan` e logo após: `terraform apply --auto-approve`.

Você verá que foi criada a **VPC** no seu **Console AWS:**
![img.png](readme_images/img.png)

---

### Criando Subnets estáticas

Para criar **subnets**, utilize o `vpc.tf` e nele vamos criar um resource de _**aws_subnet**_.

Após criado o **resource**, basta executar o comando: `terraform apply --auto-approve` e confirme na aba `VPC/Subnets` no **Console AWS**.

> Para deixar as subnets com as tags mais flexíveis, podemos utilizar o `variables.tf` e o `terraform.tfvars` para **criar a
variável** `prefix`:
![img_1.png](readme_images/img_1.png)

### Criando Subnets dinâmicas

***Obs:** Caso você tenha criado a subnet estática acima, **comente todos os resources referente a subnet** no `vpc.tf`,
execute o comando: `terraform apply --auto-approve` e **descomente a parte da subnet dinâmica**.

> **Lembre-se**, você não conseguirá rodar as subnets dinâmicas e estáticas juntas.

No arquivo `vpc.tf` vamos **criar um resource dinâmico** como a imagem e **comentar os que foram criados** acima:
![img_2.png](readme_images/img_2.png)

Execute o comando: `terraform apply --auto-approve` e confirme na aba `VPC/Subnets` no **Console AWS**.

---

### Criando Internet Gateway e Route Table

No arquivo `vpc.tf` vamos **criar 3 resources**, o primeiro será para criar o **Internet Gateway**, o segundo para criar a
**Route Table** e o terceiro para **associar as subnets na Route Table**.
![img_3.png](readme_images/img_3.png)

Execute o comando: `terraform apply --auto-approve` e confirme na aba `VPC/Internet Gateway` e `VPC/Route Table`
no **Console da AWS**.

---

### Criando Security Group

O **Security Group** servirá para proteger o _**acesso direto**_ na nossa aplicação na internet, mas permitirá que nossa aplicação
tenha acesso total na internet.

Para isso, **vamos configurar o** `cluster.tf`:
![img_4.png](readme_images/img_4.png)

Execute o comando: `terraform apply --auto-approve` e cheque na aba `VPC/Security Groups` no **Console da AWS**:
![img_5.png](readme_images/img_5.png)

---

### Criando Role e Policies

Vamos **liberar permissões para o nosso Cluster**, como por exemplo **_Auto Scaling_**, criar **_EC2_**, **_ELB_**, entre outros.

Para isso, no `cluster.tf`, vamos criar a **Role** e em seguida as **2 policies necessárias**:
![img_6.png](readme_images/img_6.png)

Execute o comando: `terraform apply --auto-approve` e cheque na aba `IAM/Roles` no **Console da AWS**:
![img_7.png](readme_images/img_7.png)

---

### Subindo Cluster EKS

**Com todas as configurações feitas**, podemos subir o `Cluster EKS`, para isso, vamos criar _**2 resources**_.

O primeiro para **salvar os logs** do nosso Cluster e o segundo para **criar o Cluster na AWS**.
![img_8.png](readme_images/img_8.png)

Execute o comando: `terraform apply --auto-approve` e aguarde a inicialização do Cluster.

Você pode visualizar a criação do Cluster na aba `EKS/Clusters` no **Console da AWS**:
![img_9.png](readme_images/img_9.png)

---

### Criando Workers para o Cluster

Vamos criar os `nós/nodes/workers` do **Cluster** e para isso utilizaremos o arquivo `node.tf`.

Antes de tudo, **criaremos uma role** para que os `nós/nodes/workers` tenham permissão no **EC2**.
![img_10.png](readme_images/img_10.png)

Agora vamos adicionar as **policies** na **Role** dos `nodes`:
![img_12.png](readme_images/img_12.png)

Execute o comando: `terraform apply --auto-approve` e confirme na aba `IAM/Roles` no **Console AWS**:
![img_11.png](readme_images/img_11.png)

Com isso feito, vamos **criar o resource** do `node`:
![img_13.png](readme_images/img_13.png)

Execute o comando novamente: `terraform apply --auto-approve` e confirme na aba `Clusters` no **Console AWS**:
![img_14.png](readme_images/img_14.png)

**Importante:**

Ao criar um **resource** de `Node Group`, sempre adicione o `instance_types` e coloque o tipo de instância que estiver
como **FREE TIER** no momento, você pode checar em: https://aws.amazon.com/pt/free
![img_15.png](readme_images/img_15.png)

---
