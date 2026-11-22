# Repositorio Digital de Proyectos y Trabajos de Grado — UES FMO

Catálogo web de trabajos de graduación y proyectos de curso de la Universidad de El Salvador,
Facultad Multidisciplinaria Oriental. El solicitante envía su trabajo, el supervisor lo revisa y
registra el permiso de los autores, y el catálogo muestra las fichas y materiales autorizados.

Esta guía explica cómo iniciar el proyecto, dónde está cada parte y cómo respaldar la base y los
archivos (RNF-06).

## Estructura

| Carpeta | Contenido |
|---|---|
| `RepositorioApi/` | API en ASP.NET Core (.NET 10) con Entity Framework Core y PostgreSQL |
| `RepositorioApi/Controllers/` | Endpoints: autenticación, proyectos, revisión, catálogo, favoritos, administración |
| `RepositorioApi/Database/` | Scripts SQL de la base |
| `RepositorioApi/App_Data/entregas/` | Archivos subidos (PDF y ZIP), una carpeta por entrega. No se sube al repositorio |
| `frontend-angular/` | Interfaz en Angular |
| `frontend-angular/src/app/catalogo/` | Catálogo público: búsqueda, filtros, ficha y favoritos |
| `frontend-angular/src/app/publicaciones/` | Envío de proyectos, Mis proyectos y notificaciones |
| `frontend-angular/src/app/gestion/` | Panel del supervisor y del administrador |

## Requisitos

- Docker Desktop
- .NET SDK 10
- Node.js 20 o superior
- pgAdmin (opcional, para ejecutar los scripts con interfaz gráfica)

## 1. Base de datos

La base corre en un contenedor de PostgreSQL 17 publicado en el puerto **5434**:

```powershell
docker run -d --name postgres17 -e POSTGRES_PASSWORD=TU_CONTRASEÑA -p 5434:5432 -v pgdata17:/var/lib/postgresql/data postgres:17
docker exec postgres17 psql -U postgres -c "CREATE DATABASE repositorio_db"
```

Los scripts los comparte el equipo y se guardan en `RepositorioApi/Database/`:

- **Base nueva:** ejecutar `000_crear_base_de_datos.sql`. Crea todas las tablas y los catálogos
  (departamentos, carreras, temáticas, tipos y las asignaturas de cada carrera). Borra lo que haya en
  el esquema `public`.
- **Base existente:** ejecutar en orden los que falten, del `002` al `007`. Cada uno se puede ejecutar
  más de una vez sin dañar nada.

Desde pgAdmin: abrir el Query Tool sobre `repositorio_db`, pegar el script y ejecutarlo con F5.
Desde PowerShell:

```powershell
Get-Content RepositorioApi\Database\000_crear_base_de_datos.sql | docker exec -i postgres17 psql -U postgres -d repositorio_db
```

## 2. Configurar la API

La cadena de conexión y la clave de los tokens van en *user-secrets*, nunca en el repositorio:

```powershell
cd RepositorioApi
dotnet user-secrets set "ConnectionStrings:RepositorioDb" "Host=localhost;Port=5434;Database=repositorio_db;Username=postgres;Password=TU_CONTRASEÑA"
dotnet user-secrets set "Jwt:Key" "UNA_CLAVE_LARGA_DE_AL_MENOS_32_CARACTERES"
dotnet user-secrets set "Jwt:Issuer" "RepositorioApi"
dotnet user-secrets set "Jwt:Audience" "RepositorioFrontend"
```

## 3. Ejecutar

API (queda en `https://localhost:7244`):

```powershell
cd RepositorioApi
dotnet dev-certs https --trust
dotnet run --launch-profile https
```

Interfaz (queda en `http://localhost:4200`):

```powershell
cd frontend-angular
npm install
npm start
```

## 4. Primer administrador

Las cuentas se crean desde **Registrarse** con el rol de solicitante. Para que una cuenta sea
administradora, después de registrarla:

```sql
INSERT INTO tbl_usuario_rol (id_usuario, id_rol)
SELECT u.id_usuario, r.id_rol FROM tbl_usuario u, tbl_rol r
WHERE u.correo = 'TU_CORREO' AND r.nombre_rol = 'administrador';
```

Desde el panel de administración se asignan los demás roles (supervisor, administrador), se registran
docentes y se gestionan materias, temáticas, carreras y departamentos. Los cambios de rol aplican al
volver a iniciar sesión.

## Pantallas por rol

| Rol | Pantallas |
|---|---|
| Lector (sin cuenta) | Catálogo `/catalogo` |
| Solicitante | Subir proyecto `/publicar`, Mis proyectos `/mis-proyectos`, Notificaciones, favoritos |
| Supervisor | Revisión `/revision-supervisor` (pendientes, publicaciones y conteo por año y área) |
| Administrador | Administración `/admin` |

## Cambiar algo del catálogo (ejemplo)

Para cambiar el texto del botón **Ver ficha del trabajo**:

1. Abrir `frontend-angular/src/app/catalogo/catalogo.html` y buscar `Ver ficha del trabajo`.
2. Cambiar el texto y guardar. Con `npm start` en marcha, el navegador se actualiza solo.
3. Comprobar en `http://localhost:4200/catalogo` que el botón muestra el texto nuevo y sigue abriendo la ficha.

Los estilos del catálogo están en `catalogo.css` y su lógica (búsqueda, filtros, favoritos) en `catalogo.ts`.

## Respaldo

Hay que guardar **dos cosas**: la base y la carpeta de archivos subidos.

```powershell
# Base de datos
docker exec postgres17 pg_dump -U postgres -d repositorio_db -F c -f /tmp/repositorio_db.backup
docker cp postgres17:/tmp/repositorio_db.backup .\respaldo\repositorio_db.backup

# Archivos subidos
Copy-Item -Recurse RepositorioApi\App_Data\entregas .\respaldo\entregas
```

Para restaurar:

```powershell
docker cp .\respaldo\repositorio_db.backup postgres17:/tmp/repositorio_db.backup
docker exec postgres17 pg_restore -U postgres -d repositorio_db --clean --if-exists /tmp/repositorio_db.backup
Copy-Item -Recurse .\respaldo\entregas RepositorioApi\App_Data\entregas
```
