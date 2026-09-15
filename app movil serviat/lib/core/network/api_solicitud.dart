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

    // Crear solicitud
    router.post(
      '/api/solicitud',
      _crearSolicitud,
    );

    return router;
  }

  // =========================================================
  // CREAR SOLICITUD
  // =========================================================

  Future<Response> _crearSolicitud(Request request) async {
    try {
      print("📩 Intentando crear una nueva solicitud...");

      // 1. Leer JSON
      final payload = await request.readAsString();

      if (payload.isEmpty) {
        return Response.badRequest(
          body: json.encode({
            "error": "El cuerpo de la solicitud está vacío",
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      final body = json.decode(payload);

      // 2. Obtener los datos
      final nombreEquipo = body['nombre_equipo'];
      final modeloEquipo = body['modelo_equipo'];
      final idCategoriaEquipo = body['id_categoria_equipo'];
      final fechaSolicitud = body['fecha_solicitud'];
      final descripcion = body['descripcion'];
      final direccionServicio = body['direccion_servicio'];
      final usuarioIdCliente = body['usuario_id_cliente'];
      final idEstadoSolicitud = body['id_estado_solicitud'];
      final usuarioIdAdministrador =
          body['usuario_id_administrador'];

      print("📦 Datos de solicitud recibidos");

      // =====================================================
      // 3. CREAR EQUIPO EN SUPABASE
      // =====================================================

      final equipoResponse = await supabase
          .from('equipo')
          .insert({
            'nombre_equipo': nombreEquipo,
            'marca_equipo': 'No especificada',
            'modelo_equipo': modeloEquipo,
            'id_categoria_equipo': idCategoriaEquipo,
          })
          .select('id')
          .single();

      final idDelNuevoEquipo = equipoResponse['id'];

      print(
        "✅ Equipo creado con ID: $idDelNuevoEquipo",
      );

      // =====================================================
      // 4. CREAR SOLICITUD EN SUPABASE
      // =====================================================

      final solicitudResponse = await supabase
          .from('solicitud')
          .insert({
            'fecha_solicitud': fechaSolicitud,
            'descripcion': descripcion,
            'direccion_servicio': direccionServicio,
            'usuario_id_administrador':
                usuarioIdAdministrador,
            'usuario_id_cliente': usuarioIdCliente,
            'id_estado_solicitud': idEstadoSolicitud,
            'id_equipo': idDelNuevoEquipo,
          })
          .select('id')
          .single();

      final idSolicitud = solicitudResponse['id'];

      print(
        "✅ Solicitud creada con ID: $idSolicitud",
      );

      // =====================================================
      // 5. RESPUESTA
      // =====================================================

      return Response.ok(
        json.encode({
          "mensaje":
              "¡Solicitud y equipo guardados en Supabase con éxito!",
          "id_solicitud": idSolicitud,
          "id_equipo": idDelNuevoEquipo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      print(
        "❌ Error creando solicitud: $e",
      );

      return Response.internalServerError(
        body: json.encode({
          "error":
              "Error al guardar el equipo o la solicitud",
          "detalle": e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }
}