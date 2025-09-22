resource "aws_ecrpublic_repository" "arroyo-ecr" {
  repository_name = "${local.proyect_name}-ecr"

}