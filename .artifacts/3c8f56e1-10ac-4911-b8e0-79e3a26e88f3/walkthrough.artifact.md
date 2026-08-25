# Implementación de Endpoints Panel Administrador

Se han implementado los servicios y modelos necesarios para conectar el panel de administrador con el backend, permitiendo la gestión completa de solicitudes de servicio.

## Cambios Realizados

### Backend Integration
- **Modelo de Datos**: Se creó [solicitud_model.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/models/solicitud_model.dart) para mapear las respuestas del servidor.
- **Servicio de Red**: Se implementó [solicitud_service.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/services/solicitud_service.dart) con los métodos:
    - `obtenerSolicitudes()`: Consulta global.
    - `actualizarSolicitud()`: Modificación de estado y técnico.
    - `eliminarSolicitud()`: Borrado físico.

### UI Improvements en [home_screen.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/screens/home/home_screen.dart)
- **Dashboard Dinámico**: Las tarjetas de estadísticas ahora muestran el conteo real filtrado por estado (Pendientes, En Proceso, Completadas, Canceladas).
- **Lista de Reservas**: La sección de "Reservas Recientes" muestra los últimos 3 registros reales.
- **Gestión Avanzada**: En la vista completa de reservas:
    - Se habilitaron los filtros por estado con contadores dinámicos.
    - Se añadió búsqueda por nombre de cliente o equipo.
    - Cada item tiene un menú (`...`) para cambiar el estado rápidamente o eliminar la solicitud.

> [!TIP]
> Asegúrate de que el servidor backend esté corriendo en la URL configurada en [app_constants.dart](file:///C:/Users/nanit/Downloads/ServiAT_Movil_Flutter_RESTAURADO/lib/core/constants/app_constants.dart) (`http://10.0.2.2:3001/api` para el emulador).

## Verificación y Solución de Problemas
- **Conexión con Dispositivo Físico**: Se detectó que estabas usando un dispositivo real (`LNA LX3`). La dirección `10.0.2.2` solo funciona para emuladores.
- **Cambio de IP**: Se actualizó `apiBaseUrl` a `http://192.168.0.15:3001/api` (la IP local de tu computador).
- **Importante**: Asegúrate de que tu celular y tu PC estén conectados a la misma red Wi-Fi y que el servidor de Node.js esté corriendo.
