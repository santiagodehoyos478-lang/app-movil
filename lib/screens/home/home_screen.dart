import 'package:flutter/material.dart';

import '../../models/producto_model.dart';
import '../../services/producto_service.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ProductoService service =
  ProductoService();

  List<ProductoModel> solicitudes = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    setState(() => cargando = true);
    
    // ID quemado para prueba
    final resultado = await service.obtenerProductos('1');

    setState(() {
      solicitudes = resultado;
      cargando = false;
    });
  }

  // ACEPTAR SOLICITUD
  Future<void> aceptarSolicitud(ProductoModel solicitud) async {
    final exito = await service.aceptarSolicitud(solicitud.id);
    if (!mounted) return;

    if (exito) {
      setState(() {
        solicitud.estado = 'Aceptada';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${solicitud.numeroSolicitud} aceptada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al aceptar solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // RECHAZAR SOLICITUD
  Future<void> rechazarSolicitud(ProductoModel solicitud) async {
    final exito = await service.rechazarSolicitud(solicitud.id);
    if (!mounted) return;

    if (exito) {
      setState(() {
        solicitud.estado = 'Rechazada';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${solicitud.numeroSolicitud} rechazada'),
          backgroundColor: Colors.red,
        ),
      );
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

      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF173F7A),

        foregroundColor: Colors.white,

        title: const Text(
          'ServiAT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        elevation: 0,
      ),

      body: Column(

        children: [

          // ENCABEZADO PANEL TÉCNICO
          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(12),

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFF214F8F),

              borderRadius:
              BorderRadius.circular(3),
            ),

            child: const Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  'Panel Técnico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Solicitudes asignadas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // LISTA
          Expanded(

            child: cargando

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : RefreshIndicator(

              onRefresh:
              cargarSolicitudes,

              child: solicitudes.isEmpty

                  ? const Center(
                child: Text(
                  'No tienes solicitudes asignadas',
                ),
              )

                  : ListView.builder(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                itemCount:
                solicitudes.length,

                itemBuilder:
                    (context, index) {

                  final solicitud =
                  solicitudes[index];

                  return ProductCard(

                    producto:
                    solicitud,

                    onAceptar: () {
                      aceptarSolicitud(
                        solicitud,
                      );
                    },

                    onRechazar: () {
                      rechazarSolicitud(
                        solicitud,
                      );
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