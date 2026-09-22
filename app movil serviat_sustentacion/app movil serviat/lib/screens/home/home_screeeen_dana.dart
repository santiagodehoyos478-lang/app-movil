import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/producto_model_dana.dart';
import '../../services/producto_serviceeee_dana.dart';
import '../../widgets/product_card_dana.dart';

class HomeDanaScreen extends StatefulWidget {
  const HomeDanaScreen({super.key});

  @override
  State<HomeDanaScreen> createState() => _HomeDanaScreenState();
}

class _HomeDanaScreenState extends State<HomeDanaScreen> {
  final ProductoDanaService service = ProductoDanaService();

  List<ProductoDanaModel> solicitudes = [];
  bool cargando = true;

  String _currentTecnicoId = '1';

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    setState(() => cargando = true);
    
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    String tecnicoId = '1'; // Default
    
    if (userStr != null) {
      final userData = jsonDecode(userStr);
      tecnicoId = (userData['id_usuario'] ?? userData['id'] ?? '1').toString();
    }

    _currentTecnicoId = tecnicoId;
    final resultado = await service.obtenerProductos(tecnicoId);

    setState(() {
      solicitudes = resultado;
      cargando = false;
    });
  }

  Future<void> aceptarSolicitud(ProductoDanaModel solicitud) async {
    final exito = await service.aceptarSolicitud(solicitud.id, _currentTecnicoId);
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${solicitud.numeroSolicitud} aceptada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      cargarSolicitudes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al aceptar solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> rechazarSolicitud(ProductoDanaModel solicitud) async {
    final exito = await service.rechazarSolicitud(solicitud.id);
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${solicitud.numeroSolicitud} rechazada'),
          backgroundColor: Colors.red,
        ),
      );
      cargarSolicitudes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al rechazar solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2448B5), // Azul oscuro marca
        foregroundColor: Colors.white,
        title: const Text(
          'ServiAT - Técnico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar Sesión",
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2448B5), Color(0xFF3B4CEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2448B5).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel de Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Solicitudes Disponibles para Atender',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE06B6B)),
                  )
                : RefreshIndicator(
                    onRefresh: cargarSolicitudes,
                    color: const Color(0xFFE06B6B),
                    child: solicitudes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay nuevas solicitudes\ndisponibles en este momento',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            itemCount: solicitudes.length,
                            itemBuilder: (context, index) {
                              final solicitud = solicitudes[index];
                              return ProductDanaCard(
                                producto: solicitud,
                                onAceptar: () {
                                  aceptarSolicitud(solicitud);
                                },
                                onRechazar: () {
                                  rechazarSolicitud(solicitud);
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}