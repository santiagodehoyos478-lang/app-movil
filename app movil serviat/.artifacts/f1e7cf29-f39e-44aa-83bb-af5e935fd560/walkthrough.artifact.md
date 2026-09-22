# Control de Acceso y Gestión de Equipo

He implementado el sistema de seguridad y gestión de usuarios solicitado, asegurando que solo el administrador principal tenga el control total sobre la creación de técnicos y otros administradores.

## Cambios Realizados

### Backend (Servidor Dart/Shelf)

- **[auth_api.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart):**
    - **Restricción Pública:** El endpoint de registro normal ahora rechaza cualquier intento de crear cuentas de "Técnico" o "Administrador". Solo permite el registro de **Clientes**.
    - **Nuevo Canal de Gestión:** Se creó la ruta `/api/admin/crear-usuario` exclusiva para el administrador. Este endpoint crea la cuenta en Supabase Auth, guarda el perfil en la base de datos y dispara automáticamente el envío del correo de bienvenida con las credenciales.

### Frontend (Aplicación Flutter)

- **[registro_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart):**
    - Se eliminaron las opciones de "Técnico" y "Administrador" del formulario público. Ahora los nuevos usuarios son Clientes por defecto.
- **[home_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/home_screen.dart) (Panel Admin):**
    - **Botón Maestro:** Se añadió un nuevo botón de **"Gestionar Equipo"** (icono de persona con un +) en la barra azul superior.
    - **Seguridad:** Este botón **solo es visible** si has iniciado sesión con el correo `dianav@gmail.com`.
    - **Formulario de Creación:** Al presionar el botón, se abre una ventana elegante donde puedes registrar el nombre, email y clave de un nuevo miembro, seleccionando si será Técnico o Administrador. Al terminar, el sistema les enviará su correo de acceso.

## Verificación

1. **Seguridad:** Si intentas registrarte como técnico desde la pantalla de bienvenida, ya no encontrarás la opción.
2. **Administración:** Entra con `dianav@gmail.com` y verás el nuevo icono para expandir tu equipo.
3. **Automatización:** Al crear un técnico desde el panel, revisa la consola del servidor; verás cómo se procesa la cuenta y se envía el correo.

> [!IMPORTANT]
> Recuerda que para que el envío de correos funcione, debes tener configuradas tus credenciales SMTP en `app_credenciales.dart`.

render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/home_screen.dart)
