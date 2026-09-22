import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import '../constants/app_credenciales.dart';

class TecnicoApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    AppConstants.supabaseUrl,
    AppConstants.publishable_key,
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
      print("🔎 [TECNICO] Consultando solicitudes disponibles (Completadas por Admin)...");

      // 1. Buscamos solicitudes en estado 3 (Listas para asignar)
      final solicitudesData = await supabase
          .from('solicitud')
          .select()
          .eq('id_estado_solicitud', 3);

      // 2. Obtener nombres de clientes y equipos con nombres de columna corregidos
      final usuariosData = await supabase.from('usuario').select('id_usuario, nombre_1, apellido_1');
      final equiposData = await supabase.from('equipo').select();

      final usuariosMap = {
        for (var u in usuariosData as List) (u['id_usuario']?.toString() ?? ''): u
      };
      final equiposMap = {
        for (var e in equiposData as List) (e['id_equipo']?.toString() ?? ''): e
      };

      // 3. Mapear al modelo del técnico
      final list = (solicitudesData as List).map((row) {
        final String clienteId = row['usuario_id_cliente']?.toString() ?? '';
        final String equipoId = row['id_equipo']?.toString() ?? '';
        
        final cliente = usuariosMap[clienteId];
        final equipo = equiposMap[equipoId];
        
        String nombreCliente = "Cliente Desconocido";
        if (cliente != null) {
          nombreCliente = "${cliente['nombre_1'] ?? ''} ${cliente['apellido_1'] ?? ''}".trim();
        }

        return {
          'id': row['id_solicitud'],
          'cliente': nombreCliente,
          'descripcion': row['descripcion'] ?? 'Sin descripción',
          'fecha': row['fecha_solicitud']?.toString() ?? '',
          'estado': row['id_estado_solicitud'] == 2 ? 'En Proceso' : 'Disponible',
          'equipo': equipo?['nombre_equipo'] ?? 'Equipo técnico',
        };
      }).toList();

      print("✅ [TECNICO] Solicitudes encontradas: ${list.length}");

      return Response.ok(
        json.encode(list),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("❌ [TECNICO] Error consultando solicitudes: $e");
      return Response.internalServerError(
        body: json.encode({"error": e.toString()}),
        headers: {'Content-Type': 'application/json'},
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