# Despliegue en EC2

Esta carpeta despliega la aplicacion en una instancia **EC2 Ubuntu 22.04** y la deja corriendo como servicio `systemd`.

La imagen de Ubuntu se resuelve desde **AWS Systems Manager Parameter Store**, lo que evita depender de filtros de nombre fragiles para el AMI. Para **Ubuntu 22.04**, Canonical publica el parametro con volumen `ebs-gp2`.

## Que crea Terraform

- una llave SSH generada automaticamente en formato `.pem`
- un `key pair` en AWS
- un `security group`
- una instancia EC2 publica
- publicacion local de la app con `dotnet publish`
- copia de los archivos a la instancia por SSH
- un servicio `systemd` para arrancar la app automaticamente

## Requisitos

- Terraform instalado
- AWS CLI configurado o variables de entorno con credenciales
- .NET 8 SDK instalado localmente

## Pasos

```bash
cd infra/ec2
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

## Que pasa durante el apply

1. Terraform genera la llave privada PEM en `keys/`
2. Crea la instancia EC2
3. Ejecuta `dotnet publish` del proyecto
4. Copia los archivos a la instancia
5. Configura y arranca el servicio

## Salidas utiles

- `app_url`
- `public_ip`
- `ssh_command`
- `pem_file`

## Probar la app

Despues del `apply`, puedes abrir:

```text
http://<public-ip>:8080
```

O usar:

```bash
curl http://<public-ip>:8080/
```

Para el endpoint `POST`:

```bash
curl -X POST http://<public-ip>:8080/saludo \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana"}'
```

## Nota importante

Por simplicidad, la configuracion de ejemplo deja abierto SSH y el puerto de la app a `0.0.0.0/0`. Para un entorno real, conviene restringir `ssh_cidr_blocks` a tu IP publica.
