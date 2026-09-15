import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'api_solicitud.dart';

void main() async {
  final api = SolicitudApi();

  // Pipeline para manejar las rutas y registrar las peticiones en consola
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(api.router.call);

  // Levanta el servidor en 0.0.0.0 para permitir conexiones desde la red local (móviles/emuladores)
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('🚀 Servidor backend corriendo en http://${server.address.host}:${server.port}');
}