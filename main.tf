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