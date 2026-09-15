import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

class AdminApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    'supabaseUrl',
    'publishable_key',
  );

  Router get router {
    final router = Router();

    // CONSULTAR SOLICITUDES
    router.get(
      '/api/admin/solicitudes',
      _consultarSolicitudesAdmin,
    );

    // ACTUALIZAR SOLICITUD
    router.put(
      '/api/admin/solicitudes/<id>',
      _actualizarSolicitudAdmin,
    );

    // ELIMINAR SOLICITUD
    router.delete(
      '/api/admin/solicitudes/<id>',
      _eliminarSolicitudAdmin,
    );

    return router;
  }

  // =========================================================
  // CONSULTAR SOLICITUDES
  // =========================================================

  Future<Response> _consultarSolicitudesAdmin(
    Request request,
  ) async {
    try {
      print("📋 Consultando solicitudes del administrador...");

      // 1. Obtener solicitudes
      final solicitudes = await supabase
          .from('solicitud')
          .select();

      // 2. Obtener equipos
      final equipos = await supabase
          .from('equipo')
          .select();

      // 3. Obtener usuarios
      final usuarios = await supabase
          .from('usuario')
          .select();

      // Convertimos los datos en mapas para buscarlos por ID
      final equiposMap = {
        for (final equipo in equipos)
          equipo['id'].toString(): equipo,
      };

      final usuariosMap = {
        for (final usuario in usuarios)
          usuario['id'].toString(): usuario,
      };

      // 4. Unir la información
      final lista = solicitudes.map((solicitud) {
        final equipo = equiposMap[
          solicitud['id_equipo']?.toString()
        ];

        final usuario = usuariosMap[
          solicitud['usuario_id_cliente']?.toString()
        ];

        return {
          ...Map<String, dynamic>.from(solicitud),

          // Datos del equipo
          'nombre_equipo':
              equipo?['nombre_equipo'] ?? '',

          'marca_equipo':
              equipo?['marca_equipo'] ?? '',

          // Datos del cliente
          'nombre_cliente':
              usuario?['nombre'] ?? '',
        };
      }).toList();

      print(
        "✅ Solicitudes encontradas: ${lista.length}",
      );

      return Response.ok(
        json.encode(lista),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print(
        "❌ Error consultando solicitudes: $e",
      );

      return Response.internalServerError(
        body: json.encode({
          "error": e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  // =========================================================
  // ACTUALIZAR SOLICITUD
  // =========================================================

  Future<Response> _actualizarSolicitudAdmin(
    Request request,
    String id,
  ) async {
    try {
      print(
        "✏️ Actualizando solicitud: $id",
      );

      final body = json.decode(
        await request.readAsString(),
      );

      await supabase
          .from('solicitud')
          .update({
            'id_estado_solicitud': body['estado'],
            'usuario_id_tecnico': body['tecnicoId'],
          })
          .eq('id', id);

      print(
        "✅ Solicitud actualizada correctamente",
      );

      return Response.ok(
        json.encode({
          "mensaje": "Solicitud actualizada",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print(
        "❌ Error actualizando solicitud: $e",
      );

      return Response.internalServerError(
        body: json.encode({
          "error": e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  // =========================================================
  // ELIMINAR SOLICITUD
  // =========================================================

  Future<Response> _eliminarSolicitudAdmin(
    Request request,
    String id,
  ) async {
    try {
      print(
        "🗑️ Eliminando solicitud: $id",
      );

      await supabase
          .from('solicitud')
          .delete()
          .eq('id', id);

      print(
        "✅ Solicitud eliminada correctamente",
      );

      return Response.ok(
        json.encode({
          "mensaje": "Solicitud eliminada",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print(
        "❌ Error eliminando solicitud: $e",
      );

      return Response.internalServerError(
        body: json.encode({
          "error": e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }
}