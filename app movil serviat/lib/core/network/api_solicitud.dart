import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';

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
    
    // Auth
    router.post('/api/registro', _registrarUsuario);
    router.post('/api/login', _loginUsuario);

    // Admin
    router.get('/api/admin/solicitudes', _consultarSolicitudesAdmin);
    router.put('/api/admin/solicitudes/<id>', _actualizarSolicitudAdmin);
    router.delete('/api/admin/solicitudes/<id>', _eliminarSolicitudAdmin);

    // Técnico
    router.get('/api/tecnico/<id>/solicitudes', _consultarSolicitudesTecnico);
    router.put('/api/tecnico/solicitud/<id>/aceptar', _aceptarSolicitudTecnico);
    router.put('/api/tecnico/solicitud/<id>/rechazar', _rechazarSolicitudTecnico);

    return router;
  }

  // --- MÓVIL: Registro ---
  Future<Response> _registrarUsuario(Request request) async {
    MySqlConnection? db;
    try {
      final body = json.decode(await request.readAsString());
      final passwordHash = BCrypt.hashpw(body['clave'], BCrypt.gensalt());

      db = await MySqlConnection.connect(dbSettings);
      
      final sql = '''
        INSERT INTO usuario (nombre, email, clave, telefono, direccion, id_rol, numero_documento, tipo_documento, fecha_nacimiento)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''';
      
      await db.query(sql, [
        body['nombre'],
        body['email'],
        passwordHash,
        body['telefono'],
        body['direccion'],
        body['id_rol'],
        body['numero_documento'],
        body['tipo_documento'],
        body['fecha_nacimiento']
      ]);

      return Response.ok(json.encode({"mensaje": "Usuario registrado con éxito"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- MÓVIL: Login ---
  Future<Response> _loginUsuario(Request request) async {
    MySqlConnection? db;
    try {
      final body = json.decode(await request.readAsString());
      db = await MySqlConnection.connect(dbSettings);

      final results = await db.query('SELECT * FROM usuario WHERE email = ?', [body['email']]);

      if (results.isEmpty) {
        return Response.forbidden(json.encode({"error": "Usuario no encontrado"}),
            headers: {'Content-Type': 'application/json'});
      }

      final user = results.first;
      if (!BCrypt.checkpw(body['clave'], user['clave'])) {
        return Response.forbidden(json.encode({"error": "Contraseña incorrecta"}),
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(json.encode({
        "id": user['id'],
        "nombre": user['nombre'],
        "email": user['email'],
        "id_rol": user['id_rol']
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- ADMIN: Consultar Solicitudes ---
  Future<Response> _consultarSolicitudesAdmin(Request request) async {
    MySqlConnection? db;
    try {
      db = await MySqlConnection.connect(dbSettings);
      final results = await db.query('''
        SELECT s.*, e.nombre_equipo, e.marca_equipo, u.nombre as nombre_cliente
        FROM solicitud s
        JOIN equipo e ON s.id_equipo = e.id
        JOIN usuario u ON s.usuario_id_cliente = u.id
      ''');

      final list = results.map((row) => row.fields).toList();
      return Response.ok(json.encode(list), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- ADMIN: Actualizar Solicitud ---
  Future<Response> _actualizarSolicitudAdmin(Request request, String id) async {
    MySqlConnection? db;
    try {
      final body = json.decode(await request.readAsString());
      db = await MySqlConnection.connect(dbSettings);

      await db.query(
        'UPDATE solicitud SET id_estado_solicitud = ?, usuario_id_tecnico = ? WHERE id = ?',
        [body['estado'], body['tecnicoId'], id]
      );

      return Response.ok(json.encode({"mensaje": "Solicitud actualizada"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- ADMIN: Eliminar Solicitud ---
  Future<Response> _eliminarSolicitudAdmin(Request request, String id) async {
    MySqlConnection? db;
    try {
      db = await MySqlConnection.connect(dbSettings);
      await db.query('DELETE FROM solicitud WHERE id = ?', [id]);
      return Response.ok(json.encode({"mensaje": "Solicitud eliminada"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- TÉCNICO: Consultar Asignadas ---
  Future<Response> _consultarSolicitudesTecnico(Request request, String id) async {
    MySqlConnection? db;
    try {
      db = await MySqlConnection.connect(dbSettings);
      final results = await db.query('''
        SELECT s.*, u.nombre as nombre_cliente, e.nombre_equipo
        FROM solicitud s
        JOIN usuario u ON s.usuario_id_cliente = u.id
        JOIN equipo e ON s.id_equipo = e.id
        WHERE s.usuario_id_tecnico = ?
      ''', [id]);

      final list = results.map((row) => row.fields).toList();
      return Response.ok(json.encode(list), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- TÉCNICO: Aceptar Solicitud ---
  Future<Response> _aceptarSolicitudTecnico(Request request, String id) async {
    MySqlConnection? db;
    try {
      db = await MySqlConnection.connect(dbSettings);
      // Estado 2: Aceptado
      await db.query('UPDATE solicitud SET id_estado_solicitud = 2 WHERE id = ?', [id]);
      
      return Response.ok(json.encode({"mensaje": "Solicitud aceptada"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
  }

  // --- TÉCNICO: Rechazar Solicitud ---
  Future<Response> _rechazarSolicitudTecnico(Request request, String id) async {
    MySqlConnection? db;
    try {
      db = await MySqlConnection.connect(dbSettings);
      // Estado 4: Cancelado/Rechazado
      await db.query('UPDATE solicitud SET id_estado_solicitud = 4 WHERE id = ?', [id]);
      
      return Response.ok(json.encode({"mensaje": "Solicitud rechazada"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await db?.close();
    }
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
