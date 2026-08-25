import '../core/network/api_client.dart';
import '../models/solicitud_model.dart';

class SolicitudService {
  final ApiClient apiClient;

  const SolicitudService({
    this.apiClient = const ApiClient(),
  });

  /// 1. Consulta de solicitudes - GET /admin/solicitudes
  Future<List<Solicitud>> obtenerSolicitudes() async {
    final data = await apiClient.get('/admin/solicitudes');

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => Solicitud.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  /// 2. Actualización de una solicitud — PUT /admin/solicitudes/:id
  Future<void> actualizarSolicitud(int id, {required String estado, int? tecnicoId}) async {
    await apiClient.put(
      '/admin/solicitudes/$id',
      body: {
        'estado': estado,
        'tecnicoId': tecnicoId,
      },
    );
  }

  /// 3. Eliminación de una solicitud — DELETE /admin/solicitudes/:id
  Future<void> eliminarSolicitud(int id) async {
    await apiClient.delete('/admin/solicitudes/$id');
  }
}
