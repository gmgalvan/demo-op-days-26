FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY HolaMicroservicio/HolaMicroservicio.csproj HolaMicroservicio/
RUN dotnet restore HolaMicroservicio/HolaMicroservicio.csproj

COPY HolaMicroservicio/. HolaMicroservicio/
WORKDIR /src/HolaMicroservicio
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "HolaMicroservicio.dll"]
