import 'package:flutter/material.dart';

class ServicioConfirmado extends StatelessWidget {
  const ServicioConfirmado({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Equivalente a useLocation().state en React
    // Obtenemos los argumentos pasados por el Navigator
    final datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    const String tecnicoNombre = "Fabio Alexander Rojas Lara";

    // 2. Equivalente al if (!location.state)
    if (datos == null || datos.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No hay datos de reserva activos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // btn-primary
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                // Equivalente a navigate("/Formulario")
                onPressed: () => Navigator.pushReplacementNamed(context, '/Formulario'),
                child: const Text("Ir al formulario", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    // 3. Renderizado principal del componente (return)
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo general suave
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // --- SECCIÓN: Icono de confirmación y Título ---
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1ABC9C), width: 3),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 48,
                        color: Color(0xFF1ABC9C),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "¡Reserva confirmada!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- SECCIÓN: Tarjeta Blanca Principal ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Validar tipo de servicio",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Por favor revisa los detalles de tu solicitud antes de confirmar",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 24),

                          // --- SUB-SECCIÓN: Resumen del servicio (Fondo rojizo) ---
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2D2D2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF2D2D2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Resumen del servicio",
                                  style: TextStyle(
                                    color: Color(0xFFFE1515),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Cuadrícula de datos simulada con Rows y Columns
                                _buildFilaDatos(
                                  "Fecha y hora:", "${datos['fechaSeleccionada'] ?? datos['fecha']} a las ${datos['horaSeleccionada'] ?? datos['hora']}",
                                  "Cliente:", "${datos['nombreCliente']}".toUpperCase(),
                                ),
                                const SizedBox(height: 12),
                                _buildFilaDatos(
                                  "Servicio:", "${datos['servicio']}",
                                  "Teléfono:", "${datos['telefono']}",
                                ),
                                const SizedBox(height: 12),
                                _buildFilaDatoUnico("Equipo:", "${datos['equipo']} (${datos['categoria']})", resaltado: true),
                                const SizedBox(height: 12),
                                _buildFilaDatoUnico("Dirección:", "${datos['direccion']}"),
                                const SizedBox(height: 12),
                                _buildFilaDatoUnico("Correo electrónico:", "${datos['gmail']}"),
                                const SizedBox(height: 12),
                                _buildFilaDatoUnico("Descripción del problema:", "${datos['descripcion']}"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- SUB-SECCIÓN: Información del Técnico (Fondo Azul) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text("Información del Técnico", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                const SizedBox(height: 8),
                                const Text("Técnico disponible", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                const SizedBox(height: 12),
                                const Text("Nombre:", style: TextStyle(fontSize: 14)),
                                Text(
                                  tecnicoNombre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- BOTÓN: Hacer otra reserva ---
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333), // Botón oscuro
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              // En Flutter solemos usar pushReplacementNamed para no apilar pantallas infinitamente
                              onPressed: () => Navigator.pushReplacementNamed(context, '/Formulario'),
                              child: const Text(
                                "Hacer otra reserva",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA EL CÓDIGO LIMPIO ---
  // Reemplazan el sistema de columnas de Bootstrap (col-12 col-md-6)

  Widget _buildFilaDatos(String titulo1, String valor1, String titulo2, String valor2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo1, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              Text(valor1, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo2, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              Text(valor2, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilaDatoUnico(String titulo, String valor, {bool resaltado = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(
          valor,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: resaltado ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}