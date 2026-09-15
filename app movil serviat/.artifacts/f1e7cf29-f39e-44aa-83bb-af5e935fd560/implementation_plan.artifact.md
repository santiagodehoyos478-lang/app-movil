# Plan de Redirección Automática por Rol tras Registro

Este plan detalla los cambios necesarios para que, al registrarse un usuario, sea redirigido automáticamente a su panel correspondiente (Técnico o Administrador) y se inicie su sesión sin tener que pasar por el login manualmente.

## Cambios Propuestos

### 1. Backend (Servidor Dart)

#### [MODIFY] [api_solicitud.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/core/network/api_solicitud.dart)
- Modificar el endpoint `_registrarUsuario` para que, tras una inserción exitosa, recupere el ID generado y retorne los datos del usuario recién creado (incluyendo `id_rol`).
- Esto permitirá al frontend guardar la sesión inmediatamente.

### 2. Frontend (App Móvil)

#### [MODIFY] [registro_screen.dart](file:///C:/Users/nanit/app-movil/app%20movil%20serviat/lib/screens/home/registro_screen.dart)
- Actualizar `_handleSubmit` para recibir el objeto de respuesta del servidor.
- Guardar los datos del usuario en `SharedPreferences` (persistir sesión).
- Implementar la lógica de redirección inmediata:
  - **Rol 2 (Técnico):** Navegar a `/dana`.
  - **Rol 3 (Administrador):** Navegar a `/dashboard`.
  - **Rol 1 (Cliente):** Navegar a `/`.

---

## Plan de Verificación

### Pruebas Manuales
1. **Registro de Técnico:**
   - Llenar el formulario eligiendo "Soy Técnico".
   - Al darle a "Registrar", la app debe mostrar "Registro Exitoso" y enviarte directamente a la pantalla con el título "Panel Técnico".
2. **Registro de Administrador:**
   - Llenar el formulario eligiendo "Soy Administrador".
   - Al darle a "Registrar", la app debe enviarte al "Dashboard" de administrador.
3. **Verificación de Sesión:**
   - Cerrar la app y volver a abrirla para confirmar que la sesión se guardó correctamente.
