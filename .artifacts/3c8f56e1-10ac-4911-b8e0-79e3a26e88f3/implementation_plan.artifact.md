# Implementación de Endpoints para el Panel de Administrador

Este plan detalla la creación de los modelos y servicios necesarios en Flutter para consumir los endpoints de administración de solicitudes (Consultar, Actualizar, Eliminar).

## Proposed Changes

### [Models]

#### [NEW] [solicitud_model.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/models/solicitud_model.dart)
Definición de la clase `Solicitud` con los campos:
- `id`: Identificador único.
- `fecha`: Fecha de la solicitud.
- `descripcion`: Detalles del problema.
- `direccion`: Ubicación del servicio.
- `estado`: Estado actual (Pendiente, En Proceso, etc.).
- `equipo`: Tipo de equipo.
- `marca`: Marca del equipo.
- `nombreCliente`: Datos básicos del cliente.
- `tecnicoId`: ID del técnico asignado (opcional).

### [Services]

#### [NEW] [solicitud_service.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/services/solicitud_service.dart)
Implementación de la clase `SolicitudService` que utiliza `ApiClient` para interactuar con:
- `GET /admin/solicitudes`: Consultar todas las solicitudes.
- `PUT /admin/solicitudes/:id`: Actualizar estado y técnico asignado.
- `DELETE /admin/solicitudes/:id`: Eliminar una solicitud.

### [Screens]

#### [MODIFY] [home_screen.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/screens/home/home_screen.dart)
Conexión de la interfaz con `SolicitudService`:
- Cargar solicitudes en el inicio.
- Actualizar los contadores de las tarjetas de estadísticas.
- Mostrar la lista real de solicitudes en la vista de reservas.
- Implementar la funcionalidad de eliminación (opcional, si la UI lo permite).

## Verification Plan

### Manual Verification
1. Verificar que al iniciar la app se realice la petición `GET /admin/solicitudes`.
2. Comprobar que los contadores del dashboard reflejen el número real de solicitudes por estado.
3. Asegurar que la lista de "Reservas Recientes" y "Ver todas" muestre la información del backend.
