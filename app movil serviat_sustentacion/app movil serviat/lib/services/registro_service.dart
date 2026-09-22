import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistroService {
  
  static const String _baseUrl = 'http://192.168.20.160:8080';

  Future<bool> registrarUsuario(Map<String, dynamic> userData) async {
    try {
      
      if (userData.containsKey('email') && userData['email'] != null) {
        userData['email'] = userData['email'].toString().trim();
      }
      if (userData.containsKey('clave') && userData['clave'] != null) {
        userData['clave'] = userData['clave'].toString().trim();
      }

      final url = '$_baseUrl/api/registro';
      print("[LOG APP] Intentando conectar a: $url");
      print("[LOG APP] Enviando datos: $userData");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 10));

      print("[LOG APP] Respuesta recibida: Código ${response.statusCode}");
      print("[LOG APP] Cuerpo: ${response.body}");

      final resBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(" ¡Registro exitoso!: ${resBody['mensaje']}");

        // Unificamos datos con el ID generado por el servidor
        final Map<String, dynamic> sessionData = {
          ...userData,
          'id': resBody['id'] ?? 0,
        };

        // Guardamos los datos de sesión localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(sessionData));

        return true;
      } else {
        print(" ERROR DEL BACKEND RECHAZANDO EL REGISTRO:");
        print("Código: ${response.statusCode}");
        print("Mensaje: ${resBody['error']}");
        return false;
      }
    } catch (e, stack) {
      print(" [LOG APP] ERROR CRÍTICO EN EL REGISTRO:");
      print("Mensaje: $e");
      print("Ruta del error (Stack): $stack");
      return false;
    }
  }
}