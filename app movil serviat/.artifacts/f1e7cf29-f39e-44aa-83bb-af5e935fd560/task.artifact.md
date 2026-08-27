# Tareas de Implementación de Endpoints y Conexión

## Backend (Dart/Shelf)
- [x] Implementar `POST /api/registro` en `api_solicitud.dart`.
- [x] Implementar `POST /api/login` en `api_solicitud.dart`.
- [x] Implementar Endpoints de Administrador en `api_solicitud.dart`:
    - [x] `GET /api/admin/solicitudes`
    - [x] `PUT /api/admin/solicitudes/:id`
    - [x] `DELETE /api/admin/solicitudes/:id`
- [x] Implementar Endpoints de Técnico en `api_solicitud.dart`:
    - [x] `GET /api/tecnico/:id/solicitudes`
    - [x] `PUT /api/tecnico/solicitud/:id/aceptar`
    - [x] `PUT /api/tecnico/solicitud/:id/rechazar`

## Frontend (Flutter)
- [x] Conectar `lib/screens/home/login_screen.dart` con el endpoint `/api/login`.
- [x] Conectar `lib/screens/home/registro_screen.dart` con el endpoint `/api/registro`.
- [x] Actualizar `lib/screens/home/ValidarServicio.dart` para usar el nuevo servidor y paleta de colores.
- [x] Centralizar URL de API en `AppConstants` y `AppDanaConstants` apuntando al servidor Dart (Puerto 8080).
- [x] Verificar funcionamiento general del flujo de autenticación y registro.
