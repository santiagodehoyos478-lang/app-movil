# Plan de Ajuste de Interfaz y Conexión a Endpoints

Este plan tiene como objetivo corregir el error de desbordamiento (overflow) en la vista del técnico y conectar los botones de "Aceptar" y "Rechazar" con el backend real.

## User Review Required

> [!IMPORTANT]
> He identificado que el error de los "cuadros amarillos" se debe a que los botones y el texto "Ver proceso de trabajo" no caben horizontalmente en pantallas pequeñas. Cambiaré el diseño a uno adaptable (`Wrap`) que moverá los elementos a la siguiente línea si es necesario.

> [!WARNING]
> Para la conexión a los endpoints, necesito una dirección IP válida. Actualmente el proyecto usa `192.168.0.15`. Asegúrate de que tu backend esté corriendo en esa dirección y puerto `3001`.

## Proposed Changes

### [Dependencias]

#### [MODIFY] [pubspec.yaml](file:///C:/Users/nanit/AndroidStudioProjects/serviat_tecnico/pubspec.yaml)
* Agregar la librería `http` para realizar las peticiones al servidor.

### [Interfaz de Usuario]

#### [MODIFY] [product_card.dart](file:///C:/Users/nanit/AndroidStudioProjects/serviat_tecnico/lib/widgets/product_card.dart)
* Cambiar el widget `Row` por un `Wrap`.
* Ajustar alineación y espaciado para que los botones se vean bien en cualquier tamaño de pantalla.

### [Lógica y Conexión]

#### [MODIFY] [producto_service.dart](file:///C:/Users/nanit/AndroidStudioProjects/serviat_tecnico/lib/services/producto_service.dart)
* Implementar `obtenerSolicitudes(String tecnicoId)` usando el endpoint `GET /api/tecnico/:id/solicitudes`.
* Implementar `aceptarSolicitud(String id)` usando el endpoint `PUT /api/tecnico/solicitud/:id/aceptar`.
* Implementar `rechazarSolicitud(String id)` (asumiendo endpoint similar).

#### [MODIFY] [products_screen.dart](file:///C:/Users/nanit/AndroidStudioProjects/serviat_tecnico/lib/screens/products/products_screen.dart)
* Actualizar la lógica para llamar al servicio real.
* Añadir manejo de errores y estados de carga.

## Verification Plan

### Manual Verification
1. Abrir la aplicación en un dispositivo o simulador y verificar que no aparezcan las líneas amarillas y negras de error.
2. Presionar "Aceptar" y verificar en la consola o backend que la petición llegue correctamente.
3. Verificar que el estado cambie visualmente en la tarjeta después de la acción.
