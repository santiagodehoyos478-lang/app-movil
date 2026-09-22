# Resumen de Endpoints del Servidor ServiAT

Este documento detalla todos los puntos de conexión (endpoints) implementados en el servidor Dart (`shelf`) de la aplicación, su funcionalidad y los datos que manejan.

---

## 📱 App Móvil (Clientes)

### 1. Registro de Usuario
- **Ruta:** `POST /api/registro`
- **Función:** Crea un nuevo usuario en la base de datos.
- **Acciones:**
  - Recibe: nombre, email, clave, teléfono, dirección, rol, documento y fecha de nacimiento.
  - Encripta la clave usando `bcrypt` antes de guardarla.
  - Inserta los datos en la tabla `usuario`.

### 2. Inicio de Sesión
- **Ruta:** `POST /api/login`
- **Función:** Autentica a un usuario existente.
- **Acciones:**
  - Busca el usuario por email.
  - Compara la clave ingresada con el hash guardado en la base de datos.
  - Retorna los datos básicos del usuario y su **ID de Rol** (Cliente, Técnico o Admin).

### 3. Crear Solicitud de Servicio
- **Ruta:** `POST /api/solicitud`
- **Función:** Registra una nueva reserva técnica.
- **Acciones:**
  - Registra primero el **Equipo** relacionado (nombre, modelo, categoría).
  - Crea la **Solicitud** vinculando el ID del equipo recién creado.
  - Guarda fecha, descripción, dirección y los IDs de cliente y administrador.

---

## 🛠️ Panel Administrador

### 4. Consultar Todas las Solicitudes
- **Ruta:** `GET /api/admin/solicitudes`
- **Función:** Obtiene el listado completo de servicios registrados.
- **Acciones:** Realiza un `JOIN` entre las tablas `solicitud`, `equipo` y `usuario` para mostrar toda la información detallada (nombre del cliente, nombre del equipo, estado, etc.).

### 5. Actualizar Solicitud (Asignar/Cambiar Estado)
- **Ruta:** `PUT /api/admin/solicitudes/<id>`
- **Función:** Permite al administrador gestionar una solicitud.
- **Acciones:** Actualiza el campo `id_estado_solicitud` y asigna un `usuario_id_tecnico` específico.

### 6. Eliminar Solicitud
- **Ruta:** `DELETE /api/admin/solicitudes/<id>`
- **Función:** Borra permanentemente una solicitud de la base de datos.

---

## 🔧 Panel Técnico

### 7. Consultar Solicitudes Asignadas
- **Ruta:** `GET /api/tecnico/<id>/solicitudes`
- **Función:** Muestra al técnico solo los trabajos que tiene pendientes.
- **Acciones:** Filtra la tabla de solicitudes por el ID del técnico y trae los datos del cliente y el equipo.

### 8. Aceptar Solicitud
- **Ruta:** `PUT /api/tecnico/solicitud/<id>/aceptar`
- **Función:** El técnico confirma que realizará el trabajo.
- **Acciones:** Cambia el estado de la solicitud a **Aceptado** (ID 2).

### 9. Rechazar Solicitud
- **Ruta:** `PUT /api/tecnico/solicitud/<id>/rechazar`
- **Función:** El técnico declina el trabajo asignado.
- **Acciones:** Cambia el estado de la solicitud a **Cancelado/Rechazado** (ID 4).

---

> [!IMPORTANT]
> Todos los endpoints retornan respuestas en formato **JSON** y manejan errores internos del servidor (500) en caso de fallos en la conexión con MySQL.
