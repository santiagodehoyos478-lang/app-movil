# ServiAT Movil - Flutter

Proyecto Flutter del panel de administrador de ServiAT.

## Estructura

- `lib/main.dart`: punto de entrada.
- `lib/app.dart`: configuración principal de MaterialApp.
- `lib/core/constants/`: constantes.
- `lib/core/network/`: cliente HTTP.
- `lib/core/theme/`: tema.
- `lib/models/`: modelos.
- `lib/screens/home/`: panel de administrador.
- `lib/screens/productos/`: pantalla de ejemplo para conservar la estructura original.
- `lib/services/`: servicios.
- `lib/widgets/`: widgets reutilizables.

## Ejecutar

1. Abrir el proyecto en VS Code.
2. Ejecutar:
   `flutter pub get`
3. Conectar un celular Android o abrir un emulador.
4. Ejecutar:
   `flutter run`

El panel actualmente usa datos de ejemplo en 0, igual que la vista React original. La conexión con la API se deja preparada en `core/network/api_client.dart`.
