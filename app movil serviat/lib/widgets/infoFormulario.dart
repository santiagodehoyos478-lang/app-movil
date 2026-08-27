import 'package:flutter/material.dart';
import '../screens/home/Formulario.dart';
import '../screens/home/ValidarServicio.dart';

class InformacionPaso1 extends StatelessWidget {
  const InformacionPaso1({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Sigue los pasos para completar tu solicitud de servicio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black87, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0), // Equivalente a p-4
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Registrar solicitud de servicio",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Estás a punto de solicitar un servicio. Haz click en continuar para proceder.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54), // text-muted
                          ),
                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF), // backgroundColor: '#eff6ff'
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade700, // border-primary
                                width: 2, // border-2
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Información importante",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Lista de viñetas
                                _buildBulletPoint("Asegúrate de tener la información del electrodoméstico"),
                                _buildBulletPoint("Prepara tu dirección completa para la visita"),
                                _buildBulletPoint("Ten a mano tu número de teléfono"),
                                _buildBulletPoint("Revisa los horarios disponibles antes de agendar"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/Formulario');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE06B6B), // Salmón/Rojo de la marca
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Continuar al Siguiente Paso",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método auxiliar para crear los elementos de la lista limpiamente
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // mb-2
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}