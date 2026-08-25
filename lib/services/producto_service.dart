import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';
import '../core/constants/app_constants.dart';

class ProductoService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<List<ProductoModel>> obtenerProductos(String tecnicoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tecnico/$tecnicoId/solicitudes'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductoModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar solicitudes');
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> aceptarSolicitud(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tecnico/solicitud/$id/aceptar'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rechazarSolicitud(String id) async {
    try {
      // Asumiendo que existe este endpoint similar al de aceptar
      final response = await http.put(
        Uri.parse('$baseUrl/tecnico/solicitud/$id/rechazar'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}