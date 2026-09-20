# Plan de Control de Acceso y Gestión de Usuarios por Administrador

Este plan restringe el acceso inicial a los paneles de Administrador y Técnico a correos específicos y permite al administrador principal gestionar la creación de nuevos miembros del equipo.

## Reglas de Negocio
1.  **Administrador Raíz:** Solo `dianav@gmail.com` tiene acceso inicial al panel de administración.
2.  **Técnico Raíz:** Solo `antonellav@gmail.com` tiene acceso inicial al panel técnico.
3.  **Registro Público:** Se deshabilitará la opción de registrarse como "Administrador" o "Técnico" desde la pantalla de registro normal. Ahora solo se podrán registrar como "Clientes".
4.  **Gestión de Equipo:** El Administrador Raíz tendrá una nueva sección para crear otros administradores y técnicos, enviándoles sus credenciales por correo automáticamente.

---

## Cambios Propuestos

### 1. Frontend (App Móvil)

#### [MODIFY] [registro_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart)
- Eliminar las opciones "Soy Técnico" y "Soy Administrador" del menú desplegable de roles.
- El registro público quedará exclusivo para **Clientes**.

#### [MODIFY] [home_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/home_screen.dart)
- Añadir un nuevo botón en la barra superior o una sección en el panel llamada **"Gestionar Equipo"**.
- Implementar un formulario flotante (Dialog) para ingresar: Nombre, Email, Contraseña y Rol (Técnico/Admin).
- Este formulario llamará al servidor para crear el usuario y enviar el correo.

#### [MODIFY] [login_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/login_screen.dart)
- Añadir una validación extra: Si alguien intenta entrar como Admin/Técnico con un correo no autorizado (que no sea el raíz o uno creado por el raíz), se le denegará el acceso.

### 2. Backend (Servidor Dart)

#### [MODIFY] [auth_api.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart)
- **Restricción de Registro:** El endpoint `/api/registro` ahora rechazará cualquier petición que intente crear un rol de Admin (3) o Técnico (2).
- **Nuevo Endpoint `/api/admin/crear-usuario`:**
    - Solo aceptará peticiones si vienen del panel de administración.
    - Creará el usuario en Supabase Auth y en la tabla `usuario`.
    - Disparará el envío del correo con las credenciales inmediatamente.

---

## Plan de Verificación

1. **Prueba de Registro:** Intentar registrarse desde la app y confirmar que ya no aparecen las opciones de Técnico/Admin.
2. **Prueba de Acceso Raíz:** Iniciar sesión con `dianav@gmail.com` y confirmar que puede ver la opción de "Gestionar Equipo".
3. **Prueba de Creación:** Crear un nuevo técnico desde el panel de admin y verificar que le llegue el correo con su clave.
4. **Prueba de Login Invitado:** Iniciar sesión con el nuevo técnico creado y confirmar que puede entrar a su panel.

> [!IMPORTANT]
> Los correos raíz `dianav@gmail.com` y `antonellav@gmail.com` ya deben existir en tu base de datos con sus respectivos roles asignados para que el sistema los reconozca al iniciar.
