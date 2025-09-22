resource "aws_ecrpublic_repository" "arroyo-ecr" {
  repository_name = "${local.proyect_name}-ecr"

}

output "ecr_repository_name" { value = aws_ecrpublic_repository.arroyo-ecr.repository_name }
output "ecr_repository_url"  { value = aws_ecrpublic_repository.arroyo-ecr.repository_uri }
