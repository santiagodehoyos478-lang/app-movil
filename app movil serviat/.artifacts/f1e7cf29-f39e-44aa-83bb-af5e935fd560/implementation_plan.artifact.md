# Plan de Notificación de Credenciales por Correo

Este plan permitirá que, tras el registro exitoso de un **Administrador** o **Técnico**, el sistema envíe automáticamente un correo electrónico al usuario con sus credenciales (correo y contraseña) para que pueda iniciar sesión.

## Consideraciones de Seguridad
> [!WARNING]
> Enviar contraseñas en texto plano por correo electrónico es una práctica de riesgo. Se recomienda que, tras el primer inicio de sesión, el sistema obligue al usuario a cambiar su contraseña. Sin embargo, se procederá según lo solicitado.

## Cambios Propuestos

### 1. Backend (Servidor Dart/Shelf)

#### [NEW] [email_service.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/email_service.dart)
- Se creará una clase `EmailService` que utilice el paquete `mailer`.
- Implementará el método `enviarCredenciales(String email, String password, int rolId)` para enviar el correo personalizado.
- **Configuración Requerida:** El usuario deberá proporcionar sus credenciales SMTP (servidor, puerto, usuario, contraseña) en `AppConstants`.

#### [MODIFY] [auth_api.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart)
- Se instanciará `EmailService`.
- En el método `_registrarUsuario`, tras la inserción exitosa en Supabase:
  - Se verificará si el `id_rol` es **2 (Técnico)** o **3 (Administrador)**.
  - Si se cumple la condición, se llamará a `emailService.enviarCredenciales` pasando el email, la clave en texto plano (antes de ser encriptada) y el rol.

#### [MODIFY] [app_credenciales.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/constants/app_credenciales.dart)
- Se añadirán las constantes necesarias para el servidor SMTP:
  - `smtpHost`
  - `smtpPort`
  - `smtpUser`
  - `smtpPass`

---

## Requerimiento para el Usuario
> [!IMPORTANT]
> Para que el sistema pueda enviar correos, necesito que me proporciones (o tú mismo llenes en el archivo `app_credenciales.dart`) los datos de un servidor de correo (ej. Gmail, SendGrid, Outlook, Mailtrap). Si usas Gmail, recuerda que debes generar una "Contraseña de aplicación".

---

## Plan de Verificación

1. **Prueba de Registro de Técnico:**
   - Registrar un nuevo usuario con el rol de "Técnico".
   - Verificar en la consola del servidor el log de envío de correo.
   - Confirmar la recepción del correo en la bandeja de entrada del usuario.
2. **Prueba de Registro de Administrador:**
   - Repetir el proceso con el rol de "Administrador".
3. **Verificación de Rol Cliente:**
   - Registrar un "Cliente" y confirmar que **NO** se le envía correo de credenciales (ya que él mismo las crea).
