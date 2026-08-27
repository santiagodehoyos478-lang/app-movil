# Plan de Implementación de Endpoints del Backend

Este plan detalla la implementación de los endpoints faltantes en el servidor Dart (`shelf`) para soportar las funcionalidades de la App Móvil, el Panel Administrador y el Panel Técnico, conectándose a la base de datos MySQL `serviat`.

## Hallazgos de Investigación

- **Servidor Actual:** El proyecto cuenta con un servidor en Dart utilizando `shelf` y `shelf_router` en `lib/core/network/server.dart`.
- **Endpoints Existentes:** Solo se encontró `POST /api/solicitud` en `lib/core/network/api_solicitud.dart`.
- **Dependencias:** El archivo `pubspec.yaml` ya incluye `bcrypt` (para encriptar contraseñas) y `mysql1` (para la base de datos).
- **Frontend:** Las pantallas de Login y Registro están usando datos simulados (mock) y no llaman a ninguna API real.

---

## Cambios Propuestos

### Componente: Backend (Dart/Shelf)

#### [MODIFY] [api_solicitud.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/api_solicitud.dart)
Se ampliará la clase `SolicitudApi` para incluir todos los endpoints solicitados, o se crearán nuevas clases si es necesario para mantener el orden. Por simplicidad y siguiendo la estructura actual, se añadirán a esta clase o se integrarán en el `Router`.

**Nuevos Endpoints a Implementar:**
1. **App Móvil:**
   - `POST /api/registro`: Registro de usuarios con encriptación `bcrypt`.
   - `POST /api/login`: Verificación de credenciales y retorno de rol del usuario.
2. **Panel Administrador:**
   - `GET /api/admin/solicitudes`: Consulta detallada de todas las solicitudes.
   - `PUT /api/admin/solicitudes/<id>`: Actualización de estado y asignación de técnico.
   - `DELETE /api/admin/solicitudes/<id>`: Eliminación de solicitud.
3. **Panel Técnico:**
   - `GET /api/tecnico/<id>/solicitudes`: Consulta de solicitudes asignadas a un técnico específico.
   - `PUT /api/tecnico/solicitud/<id>/aceptar`: Aceptar solicitud y enviar notificación (simulada o vía API de correo si está disponible).

### Componente: Frontend (Flutter)

#### [MODIFY] [login_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/login_screen.dart)
Actualizar `_handleLogin` para realizar una petición HTTP real al nuevo endpoint `/api/login`.

#### [MODIFY] [registro_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart)
Actualizar `_handleSubmit` para enviar los datos del formulario al endpoint `/api/registro`.

---

## Plan de Verificación

### Pruebas de Backend
- Realizar peticiones `POST` a `/api/registro` y verificar la creación de registros en la tabla `usuario` de MySQL.
- Probar el `/api/login` con credenciales válidas e inválidas.
- Verificar que los endpoints de Admin y Técnico retornen los datos correctos filtrados por ID o estado.

### Pruebas de Frontend
- Intentar registrar un nuevo usuario desde la app y verificar que se guarde en la base de datos.
- Iniciar sesión con el nuevo usuario y confirmar que se redirija correctamente a la pantalla de inicio.
