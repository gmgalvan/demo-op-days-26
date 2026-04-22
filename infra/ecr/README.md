# Repositorio ECR

Esta carpeta crea un repositorio **Amazon ECR** para guardar imagenes Docker del proyecto.

La configuracion esta pensada para explicar buenas practicas basicas de versionamiento:

- tags **inmutables** por defecto para evitar sobrescribir versiones publicadas
- escaneo de vulnerabilidades con `scan_on_push`
- politica de ciclo de vida para no acumular imagenes viejas

## Que crea Terraform

- un repositorio ECR
- escaneo automatico al subir imagenes
- cifrado administrado por AWS
- una politica de retencion para imagenes etiquetadas y sin tag

## Requisitos

- Terraform instalado
- AWS CLI configurado o variables de entorno con credenciales
- Docker instalado localmente

## Pasos

```bash
cd infra/ecr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

## Salidas utiles

- `repository_name`
- `repository_url`
- `registry_id`

## Practica recomendada de versionamiento

Para explicar versionamiento en clase, una convension sencilla es:

- `v1.0.0` para una version exacta e inmutable
- `v1.0` para la ultima version compatible dentro de esa serie menor
- `v1` para la ultima version mayor estable
- `latest` solo para demos o desarrollo, no como referencia principal de produccion

Si dejas `image_tag_mutability = "IMMUTABLE"`, ECR no permitira volver a subir otra imagen con el mismo tag. Eso ayuda a reforzar la idea de que `v1.0.0` debe apuntar siempre al mismo artefacto.

## Flujo ejemplo para publicar una imagen

Primero inicia sesion en ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

Construye la imagen:

```bash
docker build -t hola-microservicio:v1.0.0 .
```

Etiquetala con varias referencias:

```bash
docker tag hola-microservicio:v1.0.0 <repository-url>:v1.0.0
docker tag hola-microservicio:v1.0.0 <repository-url>:v1.0
docker tag hola-microservicio:v1.0.0 <repository-url>:v1
```

Si quieres usar `latest` en una demo, agregalo de forma explicita:

```bash
docker tag hola-microservicio:v1.0.0 <repository-url>:latest
```

Sube las imagenes:

```bash
docker push <repository-url>:v1.0.0
docker push <repository-url>:v1.0
docker push <repository-url>:v1
docker push <repository-url>:latest
```

## Nota para clase

Una forma clara de explicarlo es esta:

1. La imagen real e inmutable es `v1.0.0`.
2. Los tags `v1.0` y `v1` son alias de conveniencia.
3. `latest` no significa "la mejor" ni "produccion", solo "la ultima que alguien marco asi".
