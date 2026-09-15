import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Importamos tu archivo normal, sin prefijos
import 'auth_api.dart';
import 'solicitud_api.dart';

Middleware corsHeaders() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: headers);
    };
  };
}

void main() async {
  // 1. Instanciamos tu clase AuthApi
  final authApi = AuthApi();
  final solicitudApi = SolicitudApi();

  // 2. Combinamos las rutas en un router principal
  final router = Router()
    ..mount('/', solicitudApi.router.call)
    ..mount('/', authApi.router.call); //  Usamos la instancia de tu clase

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders()) // CORS funcionando
      .addHandler(router.call);

  // Levantamos el servidor
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('🚀 Servidor backend corriendo en http://${server.address.host}:${server.port}');
}