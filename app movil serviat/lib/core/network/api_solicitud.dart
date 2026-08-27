import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';

class SolicitudApi {
  // Configura aquí tus credenciales de MySQL
  final ConnectionSettings dbSettings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'serviat',
  );

  Router get router {
    final router = Router();
    router.post('/api/solicitud', _crearSolicitud);
    return router;
  }

  Future<Response> _crearSolicitud(Request request) async {
    MySqlConnection? db;
    try {
      // 1. Leer y decodificar el JSON de la solicitud
      final payload = await request.readAsString();
      final body = json.decode(payload);

      final nombreEquipo = body['nombre_equipo'];
      final modeloEquipo = body['modelo_equipo'];
      final idCategoriaEquipo = body['id_categoria_equipo'];
      final fechaSolicitud = body['fecha_solicitud'];
      final descripcion = body['descripcion'];
      final direccionServicio = body['direccion_servicio'];
      final usuarioIdCliente = body['usuario_id_cliente'];
      final idEstadoSolicitud = body['id_estado_solicitud'];
      final usuarioIdAdministrador = body['usuario_id_administrador'];

      // 2. Conectar a la base de datos
      db = await MySqlConnection.connect(dbSettings);

      // 3. Insertar el equipo primero
      final sqlEquipo = '''
        INSERT INTO equipo (nombre_equipo, marca_equipo, modelo_equipo, id_categoria_equipo)
        VALUES (?, 'No especificada', ?, ?)
      ''';

      final equipoResult = await db.query(sqlEquipo, [
        nombreEquipo,
        modeloEquipo,
        idCategoriaEquipo
      ]);

      final idDelNuevoEquipo = equipoResult.insertId;

      // 4. Insertar la solicitud vinculada al equipo creado
      final sqlSolicitud = '''
        INSERT INTO solicitud (fecha_solicitud, descripcion, direccion_servicio, usuario_id_administrador, usuario_id_cliente, id_estado_solicitud, id_equipo)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''';

      final valoresSolicitud = [
        fechaSolicitud,
        descripcion,
        direccionServicio,
        usuarioIdAdministrador,
        usuarioIdCliente,
        idEstadoSolicitud,
        idDelNuevoEquipo
      ];

      final solicitudResult = await db.query(sqlSolicitud, valoresSolicitud);

      // 5. Retornar éxito
      return Response.ok(
        json.encode({
          "mensaje": "¡Solicitud y equipo guardados en MySQL con éxito!",
          "id_solicitud": solicitudResult.insertId
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print("❌ Error en el servidor: $e");
      return Response.internalServerError(
        body: json.encode({"error": "Error al guardar el equipo o la solicitud"}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      // Siempre cerrar la conexión
      await db?.close();
    }
  }
}
