import 'package:flutter/material.dart';

import '../../services/producto_service.dart';
import '../../models/producto_model.dart';
import '../../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {

  final ProductoService service =
  ProductoService();

  List<ProductoModel> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => cargando = true);
    // Usando un ID de técnico quemado para prueba, deberías obtenerlo del login
    final resultado = await service.obtenerProductos('1');

    setState(() {
      productos = resultado;
      cargando = false;
    });
  }

  Future<void> _gestionarSolicitud(int index, bool aceptar) async {
    final producto = productos[index];
    final exito = aceptar 
        ? await service.aceptarSolicitud(producto.id)
        : await service.rechazarSolicitud(producto.id);

    if (exito) {
      if (!mounted) return;
      setState(() {
        productos[index].estado = aceptar ? 'Aceptada' : 'Rechazada';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud ${aceptar ? "aceptada" : "rechazada"} con éxito')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar la solicitud')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('ServiAT'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // HEADER ESTILO PANEL TÉCNICO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Técnico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Solicitudes asignadas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // LISTA DE SOLICITUDES
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : productos.isEmpty
                    ? const Center(child: Text('No tienes solicitudes asignadas'))
                    : RefreshIndicator(
                        onRefresh: cargarDatos,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              producto: productos[index],
                              onAceptar: () => _gestionarSolicitud(index, true),
                              onRechazar: () => _gestionarSolicitud(index, false),
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