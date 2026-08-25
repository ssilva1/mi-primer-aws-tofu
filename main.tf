terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "bucket-tofu-ssilva2026"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Creamos el contenedor S3 para el estado remoto
resource "aws_s3_bucket" "estado_tofu" {
  bucket        = "bucket-tofu-ssilva2026" 
  force_destroy = true # Permite borrarlo fácilmente con tofu destroy luego
}

# 2. Bloqueamos el acceso público al bucket por seguridad
resource "aws_s3_bucket_public_access_block" "bloqueo_s3" {
  bucket = aws_s3_bucket.estado_tofu.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Mantenemos nuestro grupo de logs de prueba anterior
resource "aws_cloudwatch_log_group" "mi_log_de_pruebas" {
  name              = "/mis-pruebas/primer-log"
  retention_in_days = 1
}

# 1. Crear el proveedor OIDC apuntando a la pasarela emisora de tu Action
resource "aws_iam_openid_connect_provider" "github" {
  # Cambiamos a la URL base que tu traza de depuración reportó como emisora
  url             = "https://run-actions-1-azure-eastus.actions.githubusercontent.com"
  client_id_list  = ["://amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd", "6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Actualizar el Rol de IAM para que coincida exactamente con el nuevo dominio
resource "aws_iam_role" "rol_github" {
  name = "rol-github-actions-tofu"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.github.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "run-actions-1-azure-eastus.actions.githubusercontent.com:aud": "://amazonaws.com"
        },
        "StringLike": {
          "run-actions-1-azure-eastus.actions.githubusercontent.com:sub": "repo:ssilva1/*"
        }
      }
    }
  ]
}
EOF
}

# 3. Adjuntar los permisos de administrador al nuevo rol (Se mantiene igual)
resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.rol_github.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}