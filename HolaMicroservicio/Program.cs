var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello world!");
app.MapPost("/saludo", (SaludoRequest request) =>
{
    var nombre = string.IsNullOrWhiteSpace(request.Nombre) ? "invitado" : request.Nombre.Trim();

    return Results.Ok(new
    {
        mensaje = $"Hola, {nombre}!",
        metodo = "POST",
        endpoint = "/saludo"
    });
});

app.Run();

record SaludoRequest(string? Nombre);
