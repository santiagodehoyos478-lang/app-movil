import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../services/supabase_service.dart';
import '../core/theme.dart';

class ReporteScreen extends StatefulWidget {
  final Equipo equipo;

  const ReporteScreen({super.key, required this.equipo});

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late bool _estadoActual;
  final TextEditingController _detalleController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.equipo.estado;
    _detalleController.text = widget.equipo.observacion ?? '';
  }

  Future<void> _guardarReporte() async {
    setState(() => _isSaving = true);
    try {
      await _supabaseService.actualizarEstadoEquipo(
        widget.equipo.id,
        _estadoActual,
        _detalleController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte guardado en Supabase correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Estado'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equipo seleccionado:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.equipo.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Condición actual:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('OPERATIVO'),
                    selected: _estadoActual == true,
                    selectedColor: AppTheme.successGreen.withOpacity(0.2),
                    onSelected: (selected) => setState(() => _estadoActual = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('CON FALLA'),
                    selected: _estadoActual == false,
                    selectedColor: AppTheme.errorRed.withOpacity(0.2),
                    onSelected: (selected) => setState(() => _estadoActual = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Detalle o Novedad:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _detalleController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe la novedad del equipo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : _guardarReporte,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GUARDAR EN SUPABASE', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}