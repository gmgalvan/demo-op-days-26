# HolaMicroservicio

Proyecto de ejemplo en **.NET 8** para explicar en clase que es un servicio web, como responde a una peticion HTTP y cuales son sus componentes basicos.

## Objetivo de la clase

Este proyecto sirve para mostrar, de forma sencilla, lo siguiente:

- que es un servicio web
- como un cliente hace una peticion HTTP
- como el servidor recibe la solicitud y genera una respuesta
- que es un endpoint
- como ejecutar un servicio localmente antes de desplegarlo

## Que es un servicio web

Un servicio web es una aplicacion que escucha peticiones a traves de la red y responde informacion usando protocolos estandar, normalmente **HTTP** o **HTTPS**.

En palabras simples:

- un **cliente** hace una solicitud
- el **servidor** la recibe
- el **servicio web** procesa esa solicitud
- el servidor devuelve una **respuesta**

Ejemplos cotidianos:

- una app movil consulta el clima
- un sitio web pide datos de usuarios
- un sistema escolar consulta calificaciones
- una tienda en linea obtiene productos desde una API

## Que hace este proyecto

La aplicacion expone dos endpoints sencillos:

- `GET /` devuelve el texto `Hello Open Days Students!`
- `POST /saludo` recibe un nombre en formato JSON y responde un saludo en JSON

Ese comportamiento esta definido en [Program.cs](HolaMicroservicio/Program.cs:1).

## Componentes basicos de este servicio

### 1. Cliente

Es quien consume el servicio. Puede ser:

- un navegador
- `curl`
- Postman
- otra aplicacion

### 2. Protocolo HTTP

Es el medio de comunicacion entre cliente y servidor. En este ejemplo usamos una peticion `GET`.

### 3. URL

Es la direccion a la que el cliente llama. En desarrollo, este proyecto usa:

- `http://localhost:5210/`
- `https://localhost:7095/`

### 4. Endpoint

Un endpoint es una ruta concreta que el servicio expone. En este proyecto hay dos:

- `/`
- `/saludo`

En el codigo se registra con:

```csharp
app.MapGet("/", () => "Hello Open Days Students!");
app.MapPost("/saludo", (SaludoRequest request) => ...);
```

### 5. Respuesta

Es el resultado que devuelve el servidor al cliente. En este proyecto hay dos ejemplos:

Respuesta del `GET /`:

```text
Hello Open Days Students!
```

Respuesta del `POST /saludo`:

```json
{
  "mensaje": "Hola, Ana!",
  "metodo": "POST",
  "endpoint": "/saludo"
}
```

## Flujo de una peticion

Puedes explicar el flujo asi:

1. El cliente entra a `http://localhost:5210/`.
2. El servidor de ASP.NET Core recibe la peticion.
3. El endpoint correspondiente encuentra la ruta solicitada.
4. La funcion asociada genera la respuesta.
5. El servidor devuelve el texto al cliente.

## Estructura del proyecto

- [HolaMicroservicio/](HolaMicroservicio) contiene la aplicacion ASP.NET Core
- [Program.cs](HolaMicroservicio/Program.cs:1) define el arranque de la aplicacion y el endpoint
- [HolaMicroservicio.csproj](HolaMicroservicio/HolaMicroservicio.csproj:1) indica que el proyecto usa `net8.0`
- [launchSettings.json](HolaMicroservicio/Properties/launchSettings.json:1) define la configuracion de desarrollo y los puertos
- [appsettings.json](HolaMicroservicio/appsettings.json:1) contiene configuracion general
- [appsettings.Development.json](HolaMicroservicio/appsettings.Development.json:1) contiene configuracion para ambiente de desarrollo
- [.github/workflows/](demo-open-days-2026/.github/workflows) contiene los pipelines de GitHub Actions
- [infra/ec2/](demo-open-days-2026/infra/ec2) contiene Terraform para desplegar en AWS EC2

## Explicacion rapida del codigo

El archivo [Program.cs](HolaMicroservicio/Program.cs:1) tiene tres partes importantes:

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello Open Days Students!");
app.MapPost("/saludo", (SaludoRequest request) => ...);

app.Run();
```

Que hace cada linea:

- `WebApplication.CreateBuilder(args)` prepara la configuracion de la aplicacion
- `builder.Build()` construye la aplicacion web
- `app.MapGet(...)` registra un endpoint HTTP GET
- `app.MapPost(...)` registra un endpoint HTTP POST
- `app.Run()` inicia el servidor y lo deja escuchando solicitudes

## Requisitos

- SDK de **.NET 8**

Para comprobar que esta instalado:

```bash
dotnet --info
```

## Como ejecutar el proyecto

Desde la raiz del repositorio:

```bash
cd HolaMicroservicio
dotnet run
```

Cuando arranque, el servicio quedara disponible en:

- `http://localhost:5210`
- `https://localhost:7095`

## Como probarlo en clase

### Probar `GET /` desde el navegador

Abre:

```text
http://localhost:5210/
```

### Probar `GET /` con curl

```bash
curl http://localhost:5210/
```

### Respuesta esperada

```text
Hello Open Days Students!
```

### Probar `POST /saludo` con curl

Envio del cuerpo JSON:

```bash
curl -X POST http://localhost:5210/saludo \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana"}'
```

Respuesta esperada:

```json
{
  "mensaje": "Hola, Ana!",
  "metodo": "POST",
  "endpoint": "/saludo"
}
```

### Que se puede explicar con este POST

- que `POST` se usa para enviar informacion al servidor
- que el cliente puede mandar datos en el cuerpo de la peticion
- que JSON es un formato muy comun para intercambiar datos
- que el servidor puede leer la informacion recibida y construir una respuesta dinamica

## Pipeline recomendado con GitHub Actions

Si quieres mostrar CI/CD en clase, una forma clara de explicarlo es separar el flujo en dos pipelines:

- **CI**: valida que el proyecto compila correctamente
- **CD**: publica la aplicacion en la instancia EC2

En este repositorio quedaron dos workflows:

- [.github/workflows/ci.yml](demo-open-days-2026/.github/workflows/ci.yml:1)
- [.github/workflows/deploy-ec2.yml](demo-open-days-2026/.github/workflows/deploy-ec2.yml:1)

### Que hace el pipeline de CI

El workflow `ci.yml` se ejecuta en cada `push` a `main` y en cada `pull_request`.

Sus pasos son:

1. descargar el codigo
2. instalar .NET 8
3. restaurar dependencias
4. compilar el proyecto
5. publicar los archivos de salida

Esto sirve para explicar que un pipeline no solo despliega, tambien valida que el proyecto este sano antes de llegar a produccion.

### Que hace el pipeline de deploy

El workflow `deploy-ec2.yml` se puede ejecutar manualmente o al hacer `push` a `main`.

Sus pasos son:

1. compilar y publicar la aplicacion
2. empaquetarla en un archivo `.tar.gz`
3. conectarse por SSH a la EC2
4. copiar los archivos al servidor
5. reiniciar el servicio `hola-microservicio.service`

### Secrets necesarios en GitHub

Para que el deploy funcione, en el repositorio de GitHub debes crear estos secrets:

- `EC2_HOST`: la IP publica o dominio de la instancia
- `EC2_USER`: normalmente `ubuntu`
- `EC2_SSH_PRIVATE_KEY`: el contenido completo de la llave `.pem`

En este caso, con la salida actual de Terraform, el valor de `EC2_HOST` seria:

```text
54.90.170.77
```

### Como explicarlo en clase

Puedes contarlo asi:

1. un desarrollador hace cambios en el codigo
2. GitHub Actions ejecuta el pipeline
3. primero valida que la app compila
4. despues la publica en el servidor
5. el servicio queda actualizado sin hacer el proceso manual completo

## Versionamiento

Para explicar versionamiento en clase, te recomiendo usar **Semantic Versioning** o **SemVer**:

```text
MAJOR.MINOR.PATCH
```

Ejemplo:

```text
1.4.2
```

Que significa cada parte:

- `MAJOR`: cambios grandes o incompatibles
- `MINOR`: nuevas funcionalidades compatibles
- `PATCH`: correcciones pequenas sin romper compatibilidad

### Ejemplos para este proyecto

- `1.0.0`: primera version estable del microservicio
- `1.1.0`: se agrega el endpoint `POST /saludo`
- `1.1.1`: se corrige un detalle en la respuesta
- `2.0.0`: se cambia el contrato de la API de forma incompatible

### Como versionarlo en Git

Una forma sencilla de mostrarlo es con tags:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Tambien puedes relacionarlo con el pipeline:

- cada cambio importante genera una nueva version
- cada version puede disparar un despliegue
- cada tag ayuda a identificar exactamente que codigo esta en produccion

### Seccion corta de versionamiento para un README

Si quieres una version breve y formal, podria verse asi:

```md
## Versionamiento

Este proyecto usa Semantic Versioning (SemVer).

Formato:
`MAJOR.MINOR.PATCH`

- `MAJOR`: cambios incompatibles
- `MINOR`: nuevas funcionalidades compatibles
- `PATCH`: correcciones y ajustes menores
```

## Conceptos que puedes explicar usando este ejemplo

- diferencia entre **cliente** y **servidor**
- que significa `localhost`
- que es un **puerto**
- diferencia entre `http` y `https`
- que es una **ruta**
- que es un **endpoint**
- que es una **peticion GET**
- que es una **peticion POST**
- que es una **respuesta HTTP**
- que es un **cuerpo** o body de la peticion
- que es **JSON**
- que hace un microservicio pequeño y especifico
- que es un pipeline de **CI/CD**
- que es versionamiento de software

## live

- abrir el navegador y visitar `http://localhost:5210/`
- ejecutar `curl http://localhost:5210/`
- ejecutar un `POST` con `curl` enviando un JSON
- cambiar el texto de respuesta en `Program.cs`
- detener y volver a correr la aplicacion
- mostrar que el cliente no necesita saber como esta hecho el servidor, solo la URL y el metodo HTTP

## endpoints adicionales

Si quieres ampliar este ejemplo despues, puedes agregar:

- parametros en la URL
- respuestas en formato JSON
- mas de una ruta
- codigos de estado HTTP como `200`, `404` o `500`
- conexion a una base de datos
- despliegue en un servidor o contenedor

## Como se creo

Este proyecto se genero con el template web minimo de .NET:

```bash
dotnet new web -o HolaMicroservicio
```

Despues se agrego un endpoint basico para responder un mensaje simple y validar que el microservicio corre localmente.
