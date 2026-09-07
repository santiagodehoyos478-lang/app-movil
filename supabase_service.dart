import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equipo.dart';
import '../models/salon.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<Salon>> getSalones() async {
    // Esto equivale a: SELECT id, nombre, (SELECT COUNT(*) FROM equipos WHERE salon_id = salones.id)
    final response = await _supabase
        .from('salones')
        .select('id, nombre, equipos(count)')
        .order('id');
        
    return (response as List).map((data) => Salon.fromMap(data)).toList();
  }

  // --- CREAR NUEVO SALÓN (MÉTODO NUEVO) ---
  Future<void> crearSalon(String nombre) async {
    await _supabase.from('salones').insert({
      'nombre': nombre,
    });
  }

  // --- OBTENER EQUIPOS (CON O SIN FILTRO DE SALÓN) ---
  Future<List<Equipo>> getEquipos([int? salonId]) async {
    var query = _supabase.from('equipos').select();
    final response = salonId != null ? await query.eq('salon_id', salonId) : await query;
    return (response as List).map((data) => Equipo.fromMap(data)).toList();
  }

  // --- CREAR NUEVO EQUIPO ---
  Future<void> crearEquipo({
    required int salonId,
    required String nombre,
    required String caracteristicas,
  }) async {
    await _supabase.from('equipos').insert({
      'salon_id': salonId,
      'codigo': nombre,
      'caracteristicas': caracteristicas,
      'estado': true,
      'observacion': 'OK',
    });
  }

  // --- ACTUALIZAR ESTADO Y CREAR REPORTE ---
  Future<void> actualizarEstadoEquipo(int equipoId, bool estado, String? observacion) async {
    final user = _supabase.auth.currentUser;

    // 1. Actualiza el registro del equipo
    await _supabase.from('equipos').update({
      'estado': estado,
      'observacion': observacion ?? (estado ? 'OK' : 'Con falla'),
    }).eq('id', equipoId);

    // 2. Inserta el historial en la tabla de reportes
    await _supabase.from('reportes').insert({
      'equipo_id': equipoId,
      'usuario_id': user?.id,
      'estado_reportado': estado,
      'detalle': observacion ?? 'Sin novedad detallada',
    });
  }
}