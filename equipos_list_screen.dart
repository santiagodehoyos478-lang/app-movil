import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../widgets/equipo_card.dart'; // Mantén tu tarjeta actual, si quieres que la modernicemos avísame
import '../services/supabase_service.dart';
import 'reporte_screen.dart';

class EquiposListScreen extends StatefulWidget {
  final int salonId;
  final String salonNombre;

  const EquiposListScreen({
    super.key,
    required this.salonId,
    required this.salonNombre,
  });

  @override
  State<EquiposListScreen> createState() => _EquiposListScreenState();
}

class _EquiposListScreenState extends State<EquiposListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Equipo>> _futureEquipos;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  void _cargarEquipos() {
    setState(() {
      _futureEquipos = _supabaseService.getEquipos(widget.salonId);
    });
  }

  void _mostrarModalNuevoEquipo() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController specsController = TextEditingController(text: 'Core i7 • 16GB');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Registrar Nuevo Equipo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre (ej: PC-317-31)',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: specsController,
              decoration: InputDecoration(
                labelText: 'Características',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              if (nombreController.text.isNotEmpty) {
                await _supabaseService.crearEquipo(
                  salonId: widget.salonId,
                  nombre: nombreController.text,
                  caracteristicas: specsController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _cargarEquipos();
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.salonNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            onPressed: _cargarEquipos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalNuevoEquipo,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 3,
      ),
      body: FutureBuilder<List<Equipo>>(
        future: _futureEquipos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.computer_rounded, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No hay equipos registrados.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final equipos = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 160).floor().clamp(2, 6);

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.80,
                ),
                itemCount: equipos.length,
                itemBuilder: (context, index) {
                  return EquipoCard(
                    equipo: equipos[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReporteScreen(equipo: equipos[index]),
                        ),
                      );
                      _cargarEquipos();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}