import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import 'email_service.dart';

class AuthApi {
  
  final SupabaseClient supabase = SupabaseClient(
    'https://raivkveaazorqgskolew.supabase.co',      
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhaXZrdmVhYXpvcnFnc2tvbGV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzMDQxOTIsImV4cCI6MjEwNDg4MDE5Mn0.N9BNHhBWeIbwO1zQeGPysMkWTsxHZ4k7xrZqpyV3Bnc",     // anon key (o service_role si es solo backend)
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  final EmailService emailService = EmailService();

  Router get router {
    final router = Router();

    router.post('/api/registro', _registrarUsuario);
    router.post('/api/login', _loginUsuario);
    router.post('/api/recuperar-clave', _recuperarClave);
    router.post('/api/actualizar-clave', _actualizarClave); 

    return router;
  }

  // REGISTRO (Supabase Auth + Tabla personalizada 'usuario')
  // SOLO PERMITE REGISTRAR CLIENTES (ROL 1)
  Future<Response> _registrarUsuario(Request request) async {
    print("📩 Intentando registrar usuario con Supabase Auth...");

    try {
      final payload = await request.readAsString();
      print("📦 Payload crudo recibido: $payload");

      final Map<String, dynamic> body = json.decode(payload);

      // 🛑 VALIDACIÓN DEFENSIVA: Extraemos, forzamos a String y LIMPIAMOS ESPACIOS
      final String? email = body['email']?.toString().trim();
      final String? clave = body['clave']?.toString().trim();

      print("📧 Email a registrar: '$email'");
      print("🔑 Clave a registrar: '$clave'");

      if (email == null || clave == null || email.isEmpty || clave.isEmpty) {
        return Response.badRequest(
          body: json.encode({"error": "Faltan credenciales: el email o la clave son inválidos o están vacíos."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 🛑 SEGURIDAD: El registro público SOLO permite Clientes (Rol 1)
      final int rolId = body['rol'] ?? 1;
      if (rolId != 1) {
        return Response.forbidden(
          json.encode({"error": "Solo se permite el registro público de clientes. Administradores y Técnicos deben ser creados por el administrador principal."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 1. Registramos en el sistema de Autenticación nativo de Supabase
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: clave, 
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception("No se pudo crear el usuario en Supabase Auth");
      }

      print("✅ Usuario creado en Auth con ID: ${user.id}");

      // 2. Guardamos los datos base en 'usuario' y OBTENEMOS el ID numérico generado
      final usuarioInsertado = await supabase.from('usuario').insert({
        'auth_id': user.id, 
        'nombre_1': body['nombre_1'] ?? '',
        'nombre_2': body['nombre_2'] ?? '',
        'apellido_1': body['apellido_1'] ?? '',
        'apellido_2': body['apellido_2'] ?? '',
        'tipo_documento': body['tipo_documento'],
        'documento': body['documento'],
        'clave': clave, 
        'fecha_nacimiento': body['fecha_nacimiento'],
        'id_roles': rolId, // Se fuerza a ser rolId (que ya validamos que es 1)
      }).select().single(); 

      // Extraemos el ID numérico que la base de datos generó (1, 2, 3...)
      final int idUsuarioGenerado = usuarioInsertado['id_usuario'];

      // 3. Guardamos el correo usando el ID numérico
      await supabase.from('correo_electronico').insert({
        'direccion_email': email,
        'tipo': 'personal',
        'id_usuario': idUsuarioGenerado, 
      });

      // 4. Guardamos el teléfono usando el ID numérico
      if (body['telefono'] != null) {
        await supabase.from('telefono').insert({
          'numero': body['telefono'].toString().trim(),
          'codigo_pais': body['codigo_pais'] ?? '+57',
          'tipo': 'personal',
          'id_usuario': idUsuarioGenerado, 
        });
      }

      print("✅ Perfil guardado exitosamente con el ID numérico: $idUsuarioGenerado");

      return Response.ok(
        json.encode({
          "mensaje": "Usuario registrado con éxito",
          "id": idUsuarioGenerado, 
          "id_roles": rolId
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e, stackTrace) {
      print("❌ Error en registro: $e");
      print("🔍 UBICACIÓN EXACTA DEL ERROR:\n$stackTrace"); 

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

  // LOGIN (Supabase Auth + Consulta de rol)
  Future<Response> _loginUsuario(Request request) async {
    print("🔑 Intento de inicio de sesión con Supabase Auth...");

    try {
      final payload = await request.readAsString();
      final Map<String, dynamic> body = json.decode(payload);

      // 🛑 VALIDACIÓN DEFENSIVA PARA EL LOGIN
      final String? email = body['email']?.toString().trim();
      final String? clave = body['clave']?.toString().trim();

      if (email == null || clave == null || email.isEmpty || clave.isEmpty) {
        return Response.badRequest(
          body: json.encode({"error": "Faltan credenciales para iniciar sesión."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 1. Autenticamos las credenciales usando Supabase Auth
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: clave,
      );

      final user = authResponse.user;
      if (user == null) {
        return Response.forbidden(
          json.encode({
            "error": "Credenciales inválidas",
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      // 2. Buscamos los datos extra del usuario buscando por el UUID de autenticación
      final userData = await supabase
          .from('usuario')
          .select()
          .eq('auth_id', user.id) 
          .maybeSingle();

      print("✅ Login exitoso para: ${user.email}");

      return Response.ok(
        json.encode({
          "id": userData?['id_usuario'], 
          "nombre_1": userData?['nombre_1'] ?? '',
          "apellido_1": userData?['apellido_1'] ?? '',
          "email": user.email,
          "id_roles": userData?['id_roles'],
          "token": authResponse.session?.accessToken,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e, stackTrace) { 
      print("❌ Error en login: $e");
      print("🔍 UBICACIÓN EXACTA DEL ERROR:\n$stackTrace"); 

      return Response.forbidden(
        json.encode({
          "error": "Correo o contraseña incorrectos",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  // RECUPERAR CONTRASEÑA (Envío de correo)
  Future<Response> _recuperarClave(Request request) async {
    print("🔄 Solicitud de recuperación de contraseña...");

    try {
      final payload = await request.readAsString();
      final Map<String, dynamic> body = json.decode(payload);

      final String? email = body['email']?.toString().trim();

      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: json.encode({"error": "Debes ingresar un correo válido para recuperar la contraseña."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Agregamos el redirectTo para que el correo sepa volver a la app
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'serviat://recuperar', 
      );

      print("✅ Correo de recuperación enviado a: $email");

      return Response.ok(
        json.encode({
          "mensaje": "Si el correo está registrado, recibirás un enlace para cambiar tu contraseña."
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

    } catch (e) {
      print("❌ Error al recuperar clave: $e");
      return Response.internalServerError(
        body: json.encode({"error": "Error interno al intentar enviar el correo de recuperación."}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  // ACTUALIZAR CONTRASEÑA (Guardar la nueva clave en la BD)
  Future<Response> _actualizarClave(Request request) async {
    print("🔄 Solicitud para guardar nueva contraseña...");

    try {
      final payload = await request.readAsString();
      final Map<String, dynamic> body = json.decode(payload);

      final String? token = body['token']?.toString().trim();
      final String? nuevaClave = body['nueva_clave']?.toString().trim();

      if (token == null || nuevaClave == null || token.isEmpty || nuevaClave.isEmpty) {
        return Response.badRequest(
          body: json.encode({"error": "Falta el token de seguridad o la nueva contraseña."}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 1. Usamos el token del correo para iniciar una sesión temporal
      final sessionResponse = await supabase.auth.setSession(token);
      final user = sessionResponse.user;

      if (user == null) {
        return Response.forbidden(
          json.encode({"error": "El enlace es inválido o ya expiró."}), 
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 2. Actualizamos la contraseña en Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: nuevaClave),
      );

      // 3. Actualizamos la contraseña en tu tabla 'usuario'
      await supabase.from('usuario').update({
        'clave': nuevaClave
      }).eq('auth_id', user.id);

      print("✅ Contraseña actualizada exitosamente para: ${user.email}");

      return Response.ok(
        json.encode({"mensaje": "Contraseña actualizada correctamente."}),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print("❌ Error al actualizar clave: $e");
      return Response.internalServerError(
        body: json.encode({"error": "No se pudo actualizar la contraseña."}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}