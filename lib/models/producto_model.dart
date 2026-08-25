class ProductoModel {
  final String id;
  final String numeroSolicitud;
  final String cliente;
  final String descripcion;
  final String fecha;
  String estado;

  ProductoModel({
    required this.id,
    required this.numeroSolicitud,
    required this.cliente,
    required this.descripcion,
    required this.fecha,
    required this.estado,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id']?.toString() ?? '',
      numeroSolicitud: 'Solicitud #${json['id']}',
      cliente: json['cliente'] ?? json['nombre_cliente'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fecha: json['fecha'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
    );
  }

  ProductoModel copyWith({
    String? id,
    String? numeroSolicitud,
    String? cliente,
    String? descripcion,
    String? fecha,
    String? estado,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      numeroSolicitud: numeroSolicitud ?? this.numeroSolicitud,
      cliente: cliente ?? this.cliente,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
    );
  }
}