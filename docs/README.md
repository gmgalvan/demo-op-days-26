# Pipelines de GitHub Actions

Esta carpeta documenta los workflows del proyecto para que sea facil explicarlos en clase.

Actualmente hay dos pipelines principales:

- `ci`: valida el proyecto y publica imagenes Docker en ECR
- `deploy-ec2`: publica la aplicacion en una instancia EC2 por SSH

## 1. Pipeline CI

Archivo:

- [.github/workflows/ci.yml](demo-open-days-2026/.github/workflows/ci.yml)

### Cuando se activa

Se ejecuta en estos casos:

- cuando haces `push` a `master`
- cuando haces `push` de un tag como `v1.0.0`
- cuando abres o actualizas un `pull_request`

### Que hace paso por paso

1. Hace `checkout` del repositorio.
2. Instala `.NET 8`.
3. Ejecuta `dotnet restore`.
4. Ejecuta `dotnet build` en modo `Release`.
5. Ejecuta `dotnet publish` y deja la salida en `./artifacts/publish`.
6. Calcula el tag de la imagen:
   - si fue un push normal, usa `sha-<commit>`
   - si fue un push de tag, usa tambien el tag Git, por ejemplo `v1.0.0`
7. Si no es `pull_request`, configura credenciales de AWS usando OIDC.
8. Inicia sesion en Amazon ECR.
9. Construye la imagen Docker del proyecto.
10. Hace `push` a ECR con el tag `sha-<commit>`.
11. Si el evento fue un tag Git, tambien hace `push` con ese tag, por ejemplo `v1.0.0`.

### Que publica

Publica imagenes en este repositorio ECR:

- `023890853822.dkr.ecr.us-east-1.amazonaws.com/hola-microservicio`

Ejemplos de tags:

- `sha-abc1234`
- `v1.0.0`

### Secrets que necesita

- `AWS_ROLE_TO_ASSUME`

Ese secret contiene el ARN del rol IAM que GitHub Actions usa para publicar en ECR.

## 2. Pipeline Deploy EC2

Archivo:

- [.github/workflows/deploy-ec2.yml](demo-open-days-2026/.github/workflows/deploy-ec2.yml)

### Cuando se activa

Se ejecuta en estos casos:

- cuando haces `push` a `master` y hay cambios en `HolaMicroservicio/**`
- cuando haces `push` de un tag como `v1.0.0`
- cuando lo ejecutas manualmente con `Run workflow`

### Que hace paso por paso

1. Hace `checkout` del repositorio.
2. Instala `.NET 8`.
3. Ejecuta `dotnet publish` del proyecto en `./publish`.
4. Empaqueta el resultado en `app.tar.gz`.
5. Carga la llave privada SSH desde GitHub Secrets.
6. Agrega la EC2 a `known_hosts`.
7. Copia `app.tar.gz` a la instancia EC2 con `scp`.
8. Entra por `ssh` a la instancia.
9. Descomprime la aplicacion en `/opt/hola-microservicio`.
10. Ajusta permisos del directorio.
11. Reinicia el servicio `hola-microservicio.service`.
12. Muestra el estado del servicio para confirmar que quedo levantado.

### Que despliega

Despliega la aplicacion ASP.NET Core directamente en la maquina virtual.

Importante:

- este workflow no usa Docker
- este workflow no hace `docker pull` desde ECR
- este workflow copia archivos publicados de `.NET` directamente a la EC2

## Secrets que necesita

- `EC2_HOST`
- `EC2_USER`
- `EC2_SSH_PRIVATE_KEY`

Valores esperados en este proyecto:

- `EC2_HOST`: IP publica de la instancia EC2
- `EC2_USER`: `ubuntu`
- `EC2_SSH_PRIVATE_KEY`: contenido completo del archivo PEM generado por Terraform

## 3. Diferencia entre CI y Deploy

La forma mas simple de explicarlo es esta:

- `ci` verifica que el proyecto compila y publica una imagen versionada en ECR
- `deploy-ec2` toma el codigo, lo publica y lo copia a una maquina EC2 para actualizar la app en ejecucion

En otras palabras:

- `ci` prepara el artefacto contenedorizado
- `deploy-ec2` actualiza el servidor actual

## 4. Flujo recomendado para explicarlo en clase

Puedes contarlo asi:

1. Hago un cambio en `Program.cs`.
2. Hago `push` a `master`.
3. `ci` valida el proyecto y sube una imagen a ECR con un tag tipo `sha-abc1234`.
4. `deploy-ec2` publica la app en la instancia EC2.
5. Hago `curl` a la IP publica y veo el nuevo mensaje.

Y para una version formal:

1. Creo un tag como `v1.0.0`.
2. Hago `git push origin v1.0.0`.
3. `ci` sube una imagen con `sha-abc1234` y `v1.0.0`.
4. `deploy-ec2` tambien puede ejecutarse con ese tag.
