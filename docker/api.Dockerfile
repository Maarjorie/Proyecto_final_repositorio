# API (.NET 10)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS compilar
WORKDIR /src
COPY RepositorioApi/RepositorioApi.csproj RepositorioApi/
RUN dotnet restore RepositorioApi/RepositorioApi.csproj
COPY RepositorioApi/ RepositorioApi/
RUN dotnet publish RepositorioApi/RepositorioApi.csproj -c Release -o /publicado --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=compilar /publicado .
# Archivos de ejemplo de la base de prueba
COPY docker/entregas/ App_Data/entregas/
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "RepositorioApi.dll"]
