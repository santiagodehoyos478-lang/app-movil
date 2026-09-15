import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistroService {
  // 👉 Cambia esto por la URL donde corre tu backend shelf
  // Si pruebas en emulador Android usa 10.0.2.2 en vez de localhost
  // Si pruebas en celular físico, usa la IP de tu PC (ej: 192.168.1.X)
  static const String _baseUrl = 'http://192.168.40.29:8080';

  Future<bool> registrarUsuario(Map<String, dynamic> userData) async {
    try {
      // 🛡️ LIMPIEZA DESDE EL FRONTEND (Defensa en profundidad)
      // Eliminamos espacios vacíos invisibles que el teclado del celular pueda agregar
      if (userData.containsKey('email') && userData['email'] != null) {
        userData['email'] = userData['email'].toString().trim();
      }
      if (userData.containsKey('clave') && userData['clave'] != null) {
        userData['clave'] = userData['clave'].toString().trim();
      }

      print("Iniciando registro con los siguientes datos: $userData");

      final response = await http.post(
        Uri.parse('$_baseUrl/api/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData), // Empaquetamos los datos ya limpios
      );

      final resBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ ¡Registro exitoso!: ${resBody['mensaje']}");

        // Guardamos los datos de sesión localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(userData));

        return true;
      } else {
        print("❌ ERROR DEL BACKEND RECHAZANDO EL REGISTRO:");
        print("Código: ${response.statusCode}");
        print("Mensaje: ${resBody['error']}");
        return false;
      }
    } catch (e) {
      print("❌ ERROR GENERAL EN EL REGISTRO:");
      print(e.toString());
      return false;
    }
  }
}