import 'package:flutter/material.dart';
import '../models/equipo.dart';

class EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const EquipoCard({
    super.key,
    required this.equipo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos colores basados en el estado del equipo
    final Color statusColor = equipo.estado ? Colors.green : Colors.redAccent;
    final IconData statusIcon = equipo.estado ? Icons.check_circle : Icons.warning_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de estado en la parte superior derecha
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const Spacer(),
                // Ícono central del PC
                Icon(
                  Icons.computer_rounded,
                  size: 40,
                  color: equipo.estado ? Colors.blueAccent : Colors.grey[400],
                ),
                const SizedBox(height: 12),
                // Nombre del equipo
                Text(
                  equipo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Características (ej. Core i7)
                Text(
                  equipo.caracteristicas,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}