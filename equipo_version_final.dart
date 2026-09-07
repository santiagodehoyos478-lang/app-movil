class Equipo {
  final int id;
  final int salonId;
  final String nombre;
  final String caracteristicas;
  final bool estado;
  final String? observacion;

  Equipo({
    required this.id,
    required this.salonId,
    required this.nombre,
    required this.caracteristicas,
    required this.estado,
    this.observacion,
  });

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as int,
      salonId: map['salon_id'] as int,
      nombre: map['codigo'] ?? '',
      caracteristicas: map['caracteristicas'] ?? 'Core i7 • 16GB',
      estado: map['estado'] ?? true,
      observacion: map['observacion'],
    );
  }
}