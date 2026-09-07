class Equipo {
  int? id;
  int? salonId;
  String? nombre;
  String? caracteristicas;
  bool? estado;
  String? observacion;

 
  Equipo(this.id, this.salonId, this.nombre, this.caracteristicas, this.estado, this.observacion);

 
  factory Equipo.fromMap(Map map) {
    return Equipo(
      map['id'],
      map['salon_id'],
      map['codigo'],
      map['caracteristicas'],
      map['estado'],
      map['observacion'],
    );
  }
}