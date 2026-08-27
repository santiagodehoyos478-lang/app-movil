# Implementación Completa de Backend y Conexión Frontend

He implementado todos los endpoints solicitados en el servidor Dart (`shelf`) y he conectado las pantallas de la aplicación móvil para que utilicen servicios reales en lugar de datos simulados.

## Cambios Realizados

### Backend (Dart/Shelf)
- **[api_solicitud.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/api_solicitud.dart):** Se expandió el controlador para incluir:
    - **Registro (`/api/registro`):** Guarda usuarios en MySQL con encriptación `bcrypt` para las contraseñas.
    - **Login (`/api/login`):** Valida credenciales contra la base de datos y retorna el rol del usuario.
    - **Panel Admin:** Endpoints para consultar, actualizar y eliminar solicitudes.
    - **Panel Técnico:** Endpoints para consultar solicitudes asignadas y aceptarlas/rechazarlas.
- **Configuración de Red:** Se centralizó la URL de la API en el puerto **8080** para coincidir con el servidor Dart del proyecto.

### Frontend (Flutter)
- **[login_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/login_screen.dart):** Ahora realiza una petición real al servidor. Si las credenciales son correctas, guarda la sesión del usuario.
- **[registro_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart):** Envía todos los datos del formulario (documento, dirección, rol, etc.) al backend para su almacenamiento permanente.
- **[ValidarServicio.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/ValidarServicio.dart):** Se actualizó para usar el `ApiClient` centralizado y se ajustó su paleta de colores a **Salmón y Azul Oscuro** para mantener la coherencia visual.

## Verificación

> [!IMPORTANT]
> Para que el sistema funcione, asegúrate de que tu servidor MySQL esté corriendo en `localhost:3306` con la base de datos `serviat` creada.

> [!TIP]
> Si pruebas en un dispositivo físico, asegúrate de que tanto el PC como el móvil estén en la misma red WiFi y que la IP en `AppConstants` sea la correcta.

render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/api_solicitud.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/login_screen.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/ValidarServicio.dart)
