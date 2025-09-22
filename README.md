### Debe haber conexión entre el Docker y el servicio de base de datos elegido

**Implementación**: La conexión se cablea en la Task Definition de ECS pasando `DB_HOST/DB_NAME/DB_USER` como environment y `DB_PASSWORD` como secrets (SSM).

**Salud de la app**: El healthcheck de ECS usa `pg_isready` desde el contenedor. Si la base no es alcanzable, la tarea se marca unhealthy y se reinicia, evitando servir tráfico; el ALB solo enruta a targets saludables.

**Seguridad**: El **SG de RDS** permite **5432** solo desde el **SG de las tareas ECS (no desde Internet).**

---
### Concedernos acceso a la imagen de Docker publicada

**ECR Público**: public.ecr.aws/c9t3l6c5/arroyo-ecr:latest

**Uso**:

```
docker pull public.ecr.aws/c9t3l6c5/arroyo-ecr:latest

o por commit:

docker pull public.ecr.aws/c9t3l6c5/arroyo-ecr:<SHA>
```

---

### Concedernos acceso a los archivos de Terraform creados

**Repositorio**: https://github.com/adamdaniel2993/arroyo-challenge-adan-daniel-2025

---
### Justificar por qué el tipo de servicio de cómputo y base de datos elegidos

**Cómputo (Amazon ECS en EC2, Linux)**: Control fino de capacidad (ASG + Launch Template), coste bajo en entornos pequeños, integración directa con ALB/CloudWatch, y trayectoria clara a Fargate o EKS sin reescribir la app.


**Base de datos (Amazon RDS for PostgreSQL)**: Servicio administrado (backups, parches, métricas), estándar y robusto para el reto; simplifica la conexión desde contenedor mediante variables y secretos.

--- 

### Es un plus cualquier configuración adicional realizada

* **Logs de contenedor a CloudWatch (driver `awslogs`)** en `/ecs/<proyecto>/app`.
* **Container Insights** habilitado (métricas y troubleshooting).
* **ALB access logs** en **S3** (auditoría de tráfico).
* **RDS logs** exportados a **CloudWatch Logs** (con aws_db_parameter_group).
* **Health checks** (ALB y ECS) para resiliencia de capa 7 + proceso.
* **Acceso sin SSH** mediante SSM Session Manager (se evita exponer 22/tcp).
* **Pipeline de despliegue** con **GitHub Actions** (bootstrap de backend, `terraform apply`, build & push a ECR público).

---

### Explicarnos cómo la prueba será ejecutada (Manualmente o con un pipeline)

**Opción recomendada** – Pipeline (GitHub Actions):

Workflow: `.github/workflows/challengeTerraform.yaml`

Ir a **Actions** → **challengeTerraform** → **Run workflow**, completar inputs (p. ej. `aws_region=us-east-1`, `tf_state_bucket=<bucket-s3>`, `tf_lock_table=terraform-state-locks`, `tf_state_key=arroyo-challenge/terraform.tfstate`).

El pipeline **bootstrap** el backend (S3+DynamoDB), ejecuta `terraform init` con `--backend-config`, corre `terraform apply` (crea ECR público y/o infra), y luego hace **login** → **build** → **push a ECR público**.

**Opción manual (local):**
##### Backend remoto (S3 + DynamoDB ya existentes)
```
terraform init \
  -backend-config="bucket=<BUCKET>" \
  -backend-config="key=arroyo-challenge/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-state-locks" \
  -backend-config="encrypt=true"

terraform apply

### Publicar imagen en ECR público
ECR_URI=$(terraform output -raw ecr_repository_url)
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build -t "${ECR_URI}:latest" -t "${ECR_URI}:$(git rev-parse --short HEAD)" .
docker push "${ECR_URI}:latest"
docker push "${ECR_URI}:$(git rev-parse --short HEAD)"
```
---

### Explique el uso y gestión del state file y dónde está almacenado

**Backend remoto**: S3 con versioning y cifrado de servidor (AES-256).

**Locking de estado**: DynamoDB tabla `terraform-state-locks` para evitar ejecuciones concurrentes sobre el mismo state.

Buenas prácticas: usar `terraform init -migrate-state` si cambia la config del backend; no editar el state manualmente.

---

### (Contexto de seguridad SSH)

En la configuracion del security group configure mis ips publicas para ser capaz de acceder via ssh ya que mencionan este punto en la prueba

**"Crear políticas de seguridad para el acceso SSH (por ejemplo, restricción de IPs)."**

---
### Pruebas adicionales
![img.png](img.png)

![img_1.png](img_1.png)