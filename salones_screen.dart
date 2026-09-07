import 'package:flutter/material.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import 'equipos_list_screen.dart';

class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Salon>> _futureSalones;

  @override
  void initState() {
    super.initState();
    _cargarSalones();
  }

  void _cargarSalones() {
    setState(() {
      _futureSalones = _supabaseService.getSalones();
    });
  }

  // --- Modal para registrar un salón ---
  void _mostrarModalNuevoSalon() {
    final TextEditingController nombreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Registrar Nuevo Salón', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nombreController,
          decoration: InputDecoration(
            labelText: 'Nombre (ej: Salón 317)',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              if (nombreController.text.isNotEmpty) {
                // --- AQUÍ ESTÁ EL TRY-CATCH INTEGRADO ---
                try {
                  await _supabaseService.crearSalon(nombreController.text);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Cierra la ventana
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Salón creado con éxito'), 
                        backgroundColor: Colors.green,
                      ),
                    );
                    _cargarSalones(); // Recarga la lista automáticamente
                  }
                } catch (e) {
                  // Si Supabase bloquea la inserción, te lo mostrará aquí
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear: $e'), 
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 5), // Dura más para que puedas leerlo
                      ),
                    );
                  }
                }
                // ----------------------------------------
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
        title: const Text('Salones', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            onPressed: _cargarSalones,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      // --- Botón Flotante ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalNuevoSalon,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Salón', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 3,
      ),
      body: FutureBuilder<List<Salon>>(
        future: _futureSalones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay salones registrados.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final salones = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: salones.length,
            itemBuilder: (context, index) {
              final salon = salones[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquiposListScreen(
                            salonId: salon.id,
                            salonNombre: salon.nombre,
                          ),
                        ),
                      ).then((_) {
                        // Cuando regresamos de la vista de equipos, recargamos los salones
                        _cargarSalones();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.door_front_door_outlined, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  salon.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${salon.cantidadEquipos} equipos registrados', 
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}