class Solicitud {
  final int id;
  final String fecha;
  final String descripcion;
  final String direccion;
  final String estado;
  final String equipo;
  final String marca;
  final String nombreCliente;
  final int? tecnicoId;

  const Solicitud({
    required this.id,
    required this.fecha,
    required this.descripcion,
    required this.direccion,
    required this.estado,
    required this.equipo,
    required this.marca,
    required this.nombreCliente,
    this.tecnicoId,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'] as int,
      fecha: json['fecha'] as String,
      descripcion: json['descripcion'] as String,
      direccion: json['direccion'] as String,
      estado: json['estado'] as String,
      equipo: json['equipo'] as String,
      marca: json['marca'] as String,
      nombreCliente: json['nombreCliente'] ?? json['cliente'] ?? 'Cliente desconocido',
      tecnicoId: json['tecnicoId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'descripcion': descripcion,
      'direccion': direccion,
      'estado': estado,
      'equipo': equipo,
      'marca': marca,
      'nombreCliente': nombreCliente,
      'tecnicoId': tecnicoId,
    };
  }
}
