# RDS → S3 Backup Module (Extras)

Este módulo agrega una funcionalidad opcional a la plataforma ECS/Ec2:

## ✔️ Qué hace

- Crea un bucket S3 seguro y privado para almacenar backups.
- Despliega una función Lambda dentro de la VPC para conectarse a RDS.
- Ejecuta `pg_dump` (o la herramienta que definas) y guarda el dump en S3.
- Programa la ejecución diaria vía EventBridge.
- Configura permisos IAM de privilegio mínimo:
  - Lambda solo puede leer la DB y escribir en S3.
  - No tiene permisos globales.
- Mantiene limpieza automática de backups (30 días, configurable).

## ✔️ Flujo

```

EventBridge (03:00 UTC)
↓
Lambda in VPC (SG → RDS)
↓
pg_dump / zip
↓
Upload to S3 bucket (versioned + private)

````

## ✔️ Contenido

- `s3.tf`: bucket privado + lifecycle.
- `lambda_rds_to_s3.tf`: Lambda, IAM, SG, Schedule.
- `lambda/`: código de la función (no incluido en este blueprint).

## ✔️ Cómo activarlo

En el root module:

```hcl
module "backups" {
  source      = "./extras/backups"
  environment = var.environment
}
````

Y luego:

```
terraform init
terraform apply
