# Resumen de Notificación de Credenciales por Correo

He implementado el sistema de envío automático de credenciales para que los nuevos **Administradores** y **Técnicos** reciban su acceso directamente en su bandeja de entrada al ser registrados.

## Cambios Realizados

### [email_service.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/email_service.dart) [NUEVO]
- Se creó un servicio especializado para manejar el envío de correos usando el paquete `mailer`.
- **Plantilla HTML:** El correo enviado tiene un diseño limpio y profesional, incluyendo el rol del usuario, su usuario (email) y su contraseña.

### [auth_api.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart)
- Se integró el `EmailService` dentro del flujo de registro.
- **Lógica de Envío:** Ahora, cada vez que registras a alguien, el servidor verifica si es rol 2 (Técnico) o 3 (Administrador). Si es así, dispara el envío del correo en segundo plano para no hacer esperar al administrador.

### [app_credenciales.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/constants/app_credenciales.dart)
- Se añadieron los campos necesarios para la configuración del servidor de correo.

---

## 🚀 PASO FINAL: Configura tus credenciales de correo

Para que el sistema pueda enviar los correos de verdad, **debes llenar tus datos** en el archivo:
👉 [app_credenciales.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/constants/app_credenciales.dart)

> [!IMPORTANT]
> **Si usas Gmail:**
> 1. Ve a tu Cuenta de Google > Seguridad.
> 2. Activa la "Verificación en 2 pasos".
> 3. Busca "Contraseñas de aplicaciones" y genera una nueva para "Correo".
> 4. Copia ese código de 16 letras y ponlo en `smtpPass` en el archivo de credenciales.

---

## Verificación
- El código ya está activo en tu servidor.
- Una vez que pongas tus datos de correo, cualquier registro de técnico o administrador disparará la notificación automáticamente.

render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/auth_api.dart)
render_diffs(file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/constants/app_credenciales.dart)
