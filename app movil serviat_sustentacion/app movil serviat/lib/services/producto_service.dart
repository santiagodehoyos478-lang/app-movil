import '../core/network/api_client.dart';
import '../models/producto_model.dart';

class ProductoService {
  final ApiClient apiClient;

  const ProductoService({
    this.apiClient = const ApiClient(),
  });

  Future<List<Producto>> obtenerProductos() async {
    final data = await apiClient.get('/productos');

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => Producto.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
