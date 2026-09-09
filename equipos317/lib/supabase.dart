import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> _poblarBaseDeDatos() async {
  final supabase = Supabase.instance.client;

  // 1. Crear el salón
  final salonRes = await supabase.from('salones').insert({
    'nombre': 'SALÓN 317'
  }).select('id').single();

  final String salonId = salonRes['id'];

  // 2. Generar 30 PCs
  List<Map<String, dynamic>> equiposNuevos = [];
  for (int i = 1; i <= 30; i++) {
    equiposNuevos.add({
      'codigo': 'PC-${i.toString().padLeft(2, '0')}',
      'estado': 'ok', // <-- si cambiaste la columna a texto. (Si es booleano, pon true)
      'observacion': '',
      'salon_id': salonId,
    });
  }

  // 3. Insertarlos todos de golpe
  await supabase.from('equipos').insert(equiposNuevos);
  print('¡30 computadores insertados con éxito!');
}