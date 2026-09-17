import 'package:flutter/material.dart';

import '../models/producto_model_dana.dart';

class ProductDanaCard extends StatelessWidget {
  final ProductoDanaModel producto;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const ProductDanaCard({
    super.key,
    required this.producto,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final bool pendiente = producto.estado == 'Disponible';
    final Color primaryColor = const Color(0xFFE06B6B); // Salmón de la marca
    final Color statusColor = pendiente ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Encabezado de la tarjeta con color lateral
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.05),
                border: Border(left: BorderSide(color: statusColor, width: 4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    producto.numeroSolicitud.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  _buildStatusBadge(producto.estado, statusColor),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: Icon(Icons.person_outline, size: 20, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CLIENTE",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                            ),
                            Text(
                              producto.cliente,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  
                  _infoRow(Icons.description_outlined, "Descripción", producto.descripcion),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today_outlined, "Fecha de servicio", producto.fecha),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  
                  if (pendiente) 
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAceptar,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text("ACEPTAR"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRechazar,
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text("RECHAZAR"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text("Gestionar proceso de trabajo"),
                        style: TextButton.styleFrom(foregroundColor: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String estado, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }
}