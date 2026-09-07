class Salon {
  final int id;
  final String nombre;
  final int cantidadEquipos; // Nueva variable

  Salon({
    required this.id,
    required this.nombre,
    this.cantidadEquipos = 0,
  });

  factory Salon.fromMap(Map<String, dynamic> map) {
    // Supabase devuelve el count como una lista con un mapa: [{'count': X}]
    int count = 0;
    if (map['equipos'] != null && (map['equipos'] as List).isNotEmpty) {
      count = map['equipos'][0]['count'] ?? 0;
    }

    return Salon(
      id: map['id'] as int,
      nombre: map['nombre'] ?? '',
      cantidadEquipos: count,
    );
  }
}