import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import '../constants/app_credenciales.dart';

class SolicitudApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    AppConstants.supabaseUrl,
    AppConstants.publishable_key,
  );

  Router get router {
    final router = Router();

    router.post('/api/solicitud', _crearSolicitud);

    return router;
  }

  Future<Response> _crearSolicitud(Request request) async {
    try {
      print("📩 Intentando crear solicitud en Supabase...");

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

      // ==========================================
      // 1. CREAR EQUIPO EN SUPABASE
      // ==========================================

      final equipoResponse = await supabase
          .from('equipo')
          .insert({
            'nombre_equipo': nombreEquipo,
            'marca_equipo': 'No especificada',
            'modelo_equipo': modeloEquipo,
            'id_categoria_equipo': idCategoriaEquipo,
          })
          .select('id_equipo')
          .single();

      final idDelNuevoEquipo = equipoResponse['id_equipo'];

      print("✅ Equipo creado con ID: $idDelNuevoEquipo");

      // ==========================================
      // 2. CREAR SOLICITUD EN SUPABASE
      // ==========================================

      final solicitudResponse = await supabase
          .from('solicitud')
          .insert({
            'fecha_solicitud': fechaSolicitud,
            'descripcion': descripcion,
            'direccion_servicio': direccionServicio,
            'usuario_id_administrador': usuarioIdAdministrador,
            'usuario_id_cliente': usuarioIdCliente,
            'id_estado_solicitud': idEstadoSolicitud,
            'id_equipo': idDelNuevoEquipo,
          })
          .select('id_solicitud')
          .single();

      final idSolicitud = solicitudResponse['id_solicitud'];

      print("✅ Solicitud creada con ID: $idSolicitud");

      // ==========================================
      // 3. RESPUESTA
      // ==========================================

      return Response.ok(
        json.encode({
          "mensaje": "¡Solicitud y equipo guardados en Supabase con éxito!",
          "id_solicitud": idSolicitud,
          "id_equipo": idDelNuevoEquipo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print("❌ Error en el servidor: $e");

      return Response.internalServerError(
        body: json.encode({
          "error": "Error al guardar el equipo o la solicitud",
          "detalle": e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }
}