import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Importamos tu archivo normal, sin prefijos
import 'auth_api.dart';
import 'solicitud_api.dart';
import 'admin_api.dart';
import 'tecnico_api.dart';

Middleware corsHeaders() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      print("📡 [LOG SERVIDOR] Petición entrante: ${request.method} ${request.url}");
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: headers);
    };
  };
}

void main() async {
  // 1. Instanciamos tus clases
  final authApi = AuthApi();
  final solicitudApi = SolicitudApi();
  final adminApi = AdminApi();
  final tecnicoApi = TecnicoApi();

  // 2. Combinamos las rutas en un router principal
  final router = Router()
    ..mount('/', solicitudApi.router.call)
    ..mount('/', authApi.router.call)
    ..mount('/', adminApi.router.call)
    ..mount('/', tecnicoApi.router.call); // Rutas de técnico activadas

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders()) // CORS funcionando
      .addHandler(router.call);

  // Levantamos el servidor
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('🚀 Servidor backend corriendo en http://${server.address.host}:${server.port}');
}