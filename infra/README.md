# Infraestructura AWS

La infraestructura del proyecto esta dividida en dos carpetas:

- [infra/ec2](/home/gmgalvan/demo-open-days-2026/infra/ec2) para desplegar la app en una instancia EC2
- [infra/ecr](/home/gmgalvan/demo-open-days-2026/infra/ecr) para crear un repositorio ECR y explicar versionamiento de imagenes

## EC2

La configuracion de [infra/ec2](/home/gmgalvan/demo-open-days-2026/infra/ec2) usa:

- una instancia **EC2**
- una llave **.pem** generada por Terraform
- despliegue directo de la aplicacion ASP.NET Core en la maquina
- un servicio `systemd` para dejar la app corriendo al iniciar

## ECR

La configuracion de [infra/ecr](/home/gmgalvan/demo-open-days-2026/infra/ecr) usa:

- un repositorio **Amazon ECR**
- tags inmutables por defecto
- escaneo de vulnerabilidades al subir imagenes
- politica de retencion para mantener ordenado el registro

## Flujos generales

Para EC2:

```bash
cd infra/ec2
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Para ECR:

```bash
cd infra/ecr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Los detalles y variables estan documentados en [infra/ec2/README.md](/home/gmgalvan/demo-open-days-2026/infra/ec2/README.md) y [infra/ecr/README.md](/home/gmgalvan/demo-open-days-2026/infra/ecr/README.md).
