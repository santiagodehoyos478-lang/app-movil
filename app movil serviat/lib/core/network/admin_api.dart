import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import '../constants/app_credenciales.dart';

class AdminApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    AppConstants.supabaseUrl,
    AppConstants.publishable_key,
  );

  Router get router {
    final router = Router();

    // CONSULTAR SOLICITUDES
    router.get('/api/admin/solicitudes', _consultarSolicitudesAdmin);

    // ACTUALIZAR SOLICITUD
    router.put('/api/admin/solicitudes/<id>', _actualizarSolicitudAdmin);

    // ELIMINAR SOLICITUD
    router.delete('/api/admin/solicitudes/<id>', _eliminarSolicitudAdmin);

    return router;
  }

  // =========================================================
  // CONSULTAR SOLICITUDES
  // =========================================================
  Future<Response> _consultarSolicitudesAdmin(Request request) async {
    try {
      print("📋 [ADMIN] Iniciando consulta de solicitudes...");

      // 1. Obtener solicitudes (Solo la tabla base para evitar errores de relación)
      final solicitudesData = await supabase.from('solicitud').select();
      
      // 2. Obtener usuarios para los nombres
      final usuariosData = await supabase.from('usuario').select('id_usuario, nombre_1, apellido_1');
      
      // 3. Obtener equipos
      final equiposData = await supabase.from('equipo').select();

      // Mapeo de datos para búsqueda rápida
      final usuariosMap = {
        for (var u in usuariosData as List) u['id_usuario'].toString(): u
      };
      final equiposMap = {
        for (var e in equiposData as List) e['id_equipo'].toString(): e
      };

      // Mapa local de estados (Para no depender de ninguna tabla extra)
      final estadosLocales = {
        '1': 'Pendiente',
        '2': 'En Proceso',
        '3': 'Completado',
        '4': 'Cancelado',
      };

      // 4. Unir la información en memoria
      final lista = (solicitudesData as List).map((item) {
        final cliente = usuariosMap[item['usuario_id_cliente']?.toString()];
        final equipo = equiposMap[item['id_equipo']?.toString()];
        
        final String idEstado = item['id_estado_solicitud']?.toString() ?? '1';
        final String nombreEstado = estadosLocales[idEstado] ?? 'Pendiente';

        String nombreCompleto = "Cliente Desconocido";
        if (cliente != null) {
          nombreCompleto = "${cliente['nombre_1'] ?? ''} ${cliente['apellido_1'] ?? ''}".trim();
        }

        return {
          'id': item['id_solicitud'],
          'fecha': item['fecha_solicitud']?.toString() ?? '',
          'descripcion': item['descripcion'] ?? '',
          'direccion': item['direccion_servicio'] ?? '',
          'estado': nombreEstado,
          'equipo': equipo?['nombre_equipo'] ?? 'Equipo',
          'marca': equipo?['marca_equipo'] ?? 'N/A',
          'nombreCliente': nombreCompleto,
          'tecnicoId': item['usuario_id_tecnico'],
        };
      }).toList();

      print("✅ [ADMIN] ${lista.length} solicitudes procesadas.");

      return Response.ok(
        json.encode(lista),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("❌ [ADMIN] Error en consulta: $e");
      return Response.internalServerError(
        body: json.encode({
          "error": "Error interno del servidor",
          "detalle": e.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // =========================================================
  // ACTUALIZAR SOLICITUD
  // =========================================================
  Future<Response> _actualizarSolicitudAdmin(Request request, String id) async {
    try {
      print("✏️ [ADMIN] Actualizando solicitud ID: $id");
      final body = json.decode(await request.readAsString());

      // Mapeo inverso de nombres de estado a IDs de base de datos
      final mapaNombresAId = {
        'Pendiente': 1,
        'En Proceso': 2,
        'Completado': 3,
        'Cancelado': 4,
      };

      final nuevoEstado = body['estado'];
      final int? idEstado = mapaNombresAId[nuevoEstado];

      final Map<String, dynamic> updateData = {};
      if (idEstado != null) {
        updateData['id_estado_solicitud'] = idEstado;
      }

      if (updateData.isEmpty) {
        return Response.badRequest(
            body: json.encode({"error": "Estado no válido: $nuevoEstado"}));
      }

      await supabase
          .from('solicitud')
          .update(updateData)
          .eq('id_solicitud', id);

      print("✅ [ADMIN] Solicitud $id actualizada a $nuevoEstado (ID: $idEstado)");

      return Response.ok(json.encode({"mensaje": "Solicitud actualizada correctamente"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print("❌ [ADMIN] Error al actualizar: $e");
      return Response.internalServerError(
        body: json.encode({"error": e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // =========================================================
  // ELIMINAR SOLICITUD
  // =========================================================
  Future<Response> _eliminarSolicitudAdmin(Request request, String id) async {
    try {
      print("🗑️ [ADMIN] Eliminando solicitud ID: $id");
      await supabase.from('solicitud').delete().eq('id_solicitud', id);

      return Response.ok(json.encode({"mensaje": "Solicitud eliminada"}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print("❌ [ADMIN] Error al eliminar: $e");
      return Response.internalServerError(
        body: json.encode({"error": e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
