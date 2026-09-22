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
      print("🔎 [TECNICO] Consultando solicitudes para técnico ID: $id (Disponibles o asignadas)...");

      // 1. Buscamos todas las solicitudes en estado 2 (En Proceso) o 3 (Completado/Disponible)
      final allSolicitudes = await supabase
          .from('solicitud')
          .select()
          .or('id_estado_solicitud.eq.2,id_estado_solicitud.eq.3');

      // Filtrar en memoria para asegurar máxima compatibilidad y evitar errores de sintaxis o de conversión en Postgrest
      final solicitudesData = (allSolicitudes as List).where((row) {
        final int estado = row['id_estado_solicitud'] is int 
            ? row['id_estado_solicitud'] 
            : int.tryParse(row['id_estado_solicitud']?.toString() ?? '3') ?? 3;
            
        if (estado == 3) return true; // Disponible para cualquier técnico
        if (estado == 2) {
          // Solo si está asignada a este técnico específico
          return row['usuario_id_tecnico']?.toString() == id;
        }
        return false;
      }).toList();

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

        final int idEstado = row['id_estado_solicitud'] is int 
            ? row['id_estado_solicitud'] 
            : int.tryParse(row['id_estado_solicitud']?.toString() ?? '3') ?? 3;

        return {
          'id': row['id_solicitud'],
          'cliente': nombreCliente,
          'descripcion': row['descripcion'] ?? 'Sin descripción',
          'fecha': row['fecha_solicitud']?.toString() ?? '',
          'estado': idEstado == 2 ? 'Aceptada' : 'Disponible',
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
      
      final body = json.decode(await request.readAsString());
      final int? idTecnico = body['tecnico_id'] != null ? int.tryParse(body['tecnico_id'].toString()) : null;

      await supabase
          .from('solicitud')
          .update({
            'id_estado_solicitud': 2,
            if (idTecnico != null) 'usuario_id_tecnico': idTecnico,
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