import 'package:flutter/material.dart';
import '../models/producto_model.dart';

class ProductCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const ProductCard({
    super.key,
    required this.producto,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final bool pendiente = producto.estado == 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(4),

        border: Border.all(
          color: Colors.grey.shade300,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // NÚMERO DE SOLICITUD
            Text(
              producto.numeroSolicitud,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            // CLIENTE
            Text(
              'Cliente: ${producto.cliente}',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 6),

            // DESCRIPCIÓN
            Text(
              'Descripción: ${producto.descripcion}',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 6),

            // FECHA
            Text(
              'Fecha: ${producto.fecha}',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 14),

            // BOTONES ADAPTADOS PARA EVITAR OVERFLOW
            Wrap(
              spacing: 8, // Espacio horizontal entre botones
              runSpacing: 8, // Espacio vertical si saltan de línea
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (pendiente) ...[
                  // ACEPTAR
                  ElevatedButton(
                    onPressed: onAceptar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF198754),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // RECHAZAR
                  ElevatedButton(
                    onPressed: onRechazar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                // VER PROCESO DE TRABAJO
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Proceso de ${producto.numeroSolicitud}',
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Ver proceso de trabajo',
                    style: TextStyle(
                      color: Color(0xFF0D6EFD),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            // MOSTRAR ESTADO DESPUÉS DE ACEPTAR O RECHAZAR
            if (!pendiente) ...[

              const SizedBox(height: 5),

              Align(
                alignment: Alignment.centerRight,

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color:
                    producto.estado == 'Aceptada'
                        ? Colors.green.shade100
                        : Colors.red.shade100,

                    borderRadius:
                    BorderRadius.circular(4),
                  ),

                  child: Text(
                    producto.estado,
                    style: TextStyle(
                      fontSize: 11,

                      fontWeight: FontWeight.bold,

                      color:
                      producto.estado == 'Aceptada'
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}