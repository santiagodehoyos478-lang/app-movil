import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import '../constants/app_credenciales.dart';
import 'email_service.dart'; 

class AdminApi {
  // Conexión con Supabase
  final SupabaseClient supabase = SupabaseClient(
    AppConstants.supabaseUrl,
    AppConstants.publishable_key,
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  // Servicio de correos para enviar credenciales a los nuevos usuarios
  final EmailService emailService = EmailService();

  Router get router {
    final router = Router();

    // CONSULTAR SOLICITUDES
    router.get('/api/admin/solicitudes', _consultarSolicitudesAdmin);

    // ACTUALIZAR SOLICITUD
    router.put('/api/admin/solicitudes/<id>', _actualizarSolicitudAdmin);

    // ELIMINAR SOLICITUD
    router.delete('/api/admin/solicitudes/<id>', _eliminarSolicitudAdmin);
    
    // Nueva ruta para que el admin cree usuarios (Técnicos o Admins)
    router.post('/api/admin/crear-usuario', _registrarUsuarioPorAdmin); 

    return router;
  }

  // =========================================================
  // CREAR USUARIO DESDE PANEL ADMIN
  // =========================================================
  Future<Response> _registrarUsuarioPorAdmin(Request request) async {
    print("👨‍💼 Administrador intentando crear nuevo usuario...");

    try {
      final payload = await request.readAsString();
      final Map<String, dynamic> body = json.decode(payload);

      final String? email = body['email']?.toString().trim();
      final String? clave = body['clave']?.toString().trim();
      final int rolId = body['rol'] ?? 2; // Por defecto Técnico (2)

      if (email == null || clave == null || email.isEmpty || clave.isEmpty) {
        return Response.badRequest(
          body: json.encode({"error": "Datos incompletos para crear el usuario."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 1. Registro en Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: clave, 
      );

      final user = authResponse.user;
      if (user == null) throw Exception("Error al crear cuenta en Supabase Auth");

      // 2. Guardar en tabla 'usuario'
      final usuarioInsertado = await supabase.from('usuario').insert({
        'auth_id': user.id, 
        'nombre_1': body['nombre_1'] ?? 'Usuario',
        'apellido_1': body['apellido_1'] ?? 'Nuevo',
        'tipo_documento': body['tipo_documento'] ?? 'CC',
        'documento': body['documento'] ?? user.id.substring(0, 8),
        'clave': clave, 
        'id_roles': rolId,
        'fecha_nacimiento': body['fecha_nacimiento'] ?? '2000-01-01',
      }).select().single(); 

      final int idUsuarioGenerado = usuarioInsertado['id_usuario'];

      // 3. Relaciones extra (Correo electrónico de trabajo)
      await supabase.from('correo_electronico').insert({
        'direccion_email': email,
        'tipo': 'trabajo',
        'id_usuario': idUsuarioGenerado, 
      });

      print("✅ Usuario creado por admin: $email con ID: $idUsuarioGenerado");

      // 4. ENVÍO DE CORREO DE CREDENCIALES
      emailService.enviarCredenciales(email, clave, rolId).catchError((e) {
        print("🚨 Error enviando correo desde admin: $e");
      });

      return Response.ok(
        json.encode({"mensaje": "Usuario creado y credenciales enviadas."}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("❌ Error en creación por admin: $e");
      return Response.internalServerError(
        body: json.encode({"error": e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
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