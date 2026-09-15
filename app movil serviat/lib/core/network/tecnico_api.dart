import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

class TecnicoApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    'supabaseUrl',
    'publishable_key',
  );

  Router get router {
    final router = Router();

    router.get(
      '/api/tecnico/<id>/solicitudes',
      _consultarSolicitudesTecnico,
    );

    router.put(
      '/api/tecnico/solicitud/<id>/aceptar',
      _aceptarSolicitudTecnico,
    );

    router.put(
      '/api/tecnico/solicitud/<id>/rechazar',
      _rechazarSolicitudTecnico,
    );

    return router;
  }

  // =========================================================
  // CONSULTAR SOLICITUDES ASIGNADAS AL TÉCNICO
  // =========================================================

  Future<Response> _consultarSolicitudesTecnico(
    Request request,
    String id,
  ) async {
    try {
      print("🔎 Consultando solicitudes del técnico: $id");

      final results = await supabase
          .from('solicitud')
          .select('''
            *,
            usuario:usuario_id_cliente (
              nombre
            ),
            equipo:id_equipo (
              nombre_equipo
            )
          ''')
          .eq('usuario_id_tecnico', id);

      final list = results.map((row) {
        return {
          ...row,
          'nombre_cliente': row['usuario']?['nombre'] ?? '',
          'nombre_equipo': row['equipo']?['nombre_equipo'] ?? '',
        };
      }).toList();

      print("✅ Solicitudes encontradas: ${list.length}");

      return Response.ok(
        json.encode(list),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print("❌ Error consultando solicitudes: $e");

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
  // ACEPTAR SOLICITUD
  // =========================================================

  Future<Response> _aceptarSolicitudTecnico(
    Request request,
    String id,
  ) async {
    try {
      print("✅ Aceptando solicitud: $id");

      await supabase
          .from('solicitud')
          .update({
            'id_estado_solicitud': 2,
          })
          .eq('id_solicitud', int.parse(id));

      return Response.ok(
        json.encode({
          "mensaje": "Solicitud aceptada",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print("❌ Error aceptando solicitud: $e");

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
  // RECHAZAR SOLICITUD
  // =========================================================

  Future<Response> _rechazarSolicitudTecnico(
    Request request,
    String id,
  ) async {
    try {
      print("❌ Rechazando solicitud: $id");

      await supabase
          .from('solicitud')
          .update({
            'id_estado_solicitud': 4,
          })
          .eq('id_solicitud', int.parse(id));

      return Response.ok(
        json.encode({
          "mensaje": "Solicitud rechazada",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print("❌ Error rechazando solicitud: $e");

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