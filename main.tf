terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configura el proveedor de AWS
provider "aws" {
  region = "us-east-1"
}

# Creamos un recurso gratis para probar: Un grupo de logs vacío
resource "aws_cloudwatch_log_group" "mi_log_de_pruebas" {
  name              = "/mis-pruebas/primer-log"
  retention_in_days = 1
}