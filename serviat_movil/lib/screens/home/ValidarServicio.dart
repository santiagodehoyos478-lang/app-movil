import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ValidarInformacion extends StatefulWidget {
  const ValidarInformacion({super.key});

  @override
  State<ValidarInformacion> createState() => _ValidarInformacionState();
}

class _ValidarInformacionState extends State<ValidarInformacion> {
  bool _cargando = false;

  // Paleta de colores
  final Color azulRey = const Color(0xFF0D6EFD);
  final Color salmon = const Color(0xFFFF7E67);
  final Color fondoApp = const Color(0xFFF8FAFC);

  // IMPORTANTE: Si estás probando en el emulador de Android, localhost no funciona.
  // Debes usar la IP 10.0.2.2 que apunta al localhost de tu computadora.
  // Si pruebas en web o dispositivo físico conectado por red, cambia esto por tu IP local (ej. 192.168.x.x)
  final String _baseUrl = 'http://10.0.2.2:3001/api';

  Future<void> _confirmarReserva(Map<String, dynamic> datos) async {
    setState(() {
      _cargando = true;
    });

    try {


      final int idEstadoPendiente = 1;
      final int idCategoria = datos['categoria'] == "Industrial" ? 1 : 2;
      final int idAdministrador = 1;

      // 1. Objeto para guardar en MySQL a través de tu API Node.js
      final Map<String, dynamic> datosParaMySQL = {
        "nombre_equipo": datos['equipo'],
        "modelo_equipo": datos['modelo']?.isNotEmpty == true ? datos['modelo'] : "N/A",
        "id_categoria_equipo": idCategoria,
        "fecha_solicitud": datos['fechaSeleccionada'],
        "descripcion": datos['descripcion'],
        "direccion_servicio": datos['direccion'],
        "id_estado_solicitud": idEstadoPendiente,
        "usuario_id_administrador": idAdministrador
      };

      // Petición a la base de datos
      final respuestaDb = await http.post(
        Uri.parse('$_baseUrl/solicitud'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datosParaMySQL),
      );

      if (respuestaDb.statusCode != 200 && respuestaDb.statusCode != 201) {
        final errorMsg = jsonDecode(respuestaDb.body)['error'] ?? "Error al guardar en el servidor";
        throw Exception(errorMsg);
      }

      // 2. Enviar notificaciones por correo
      final Map<String, dynamic> datosNotificaciones = {
        "email": datos['gmail'],
        "nombreCliente": datos['nombreCliente'],
        "equipo": datos['equipo'],
        "fecha": datos['fechaSeleccionada'],
        "hora": datos['horaSeleccionada'],
        "estado": "Pendiente"
      };

      final respuestaNotificacion = await http.post(
        Uri.parse('$_baseUrl/notificaciones/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datosNotificaciones),
      );

      // Independientemente de si el correo falla o no (como en tu código original), mostramos éxito
      await _mostrarAlerta(
          "¡Reserva Confirmada!",
          "Se ha guardado tu solicitud y ${respuestaNotificacion.statusCode == 200 ? 'enviado el correo de confirmación' : 'estamos procesando la notificación'}.",
          true
      );

      if (!mounted) return;
      // Navegamos a la pantalla final enviando los datos
      Navigator.pushReplacementNamed(context, '/ServicioConfirmado', arguments: datos);

    } catch (error) {
      await _mostrarAlerta("Error al confirmar", error.toString().replaceAll("Exception: ", ""), false);
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Reemplazo de SweetAlert2
  Future<void> _mostrarAlerta(String titulo, String mensaje, bool exito) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a tocar el botón
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: exito ? azulRey : Colors.red, width: 2),
          ),
          title: Row(
            children: [
              Icon(exito ? Icons.check_circle : Icons.error, color: exito ? azulRey : Colors.red, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: exito ? azulRey : Colors.red))),
            ],
          ),
          content: Text(mensaje, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulRey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recibimos los datos enviados desde la pantalla anterior a través de Navigator.pushNamed
    final datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text("Validar Información"),
        backgroundColor: azulRey,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text("Sigue los pasos para completar tu solicitud", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const SizedBox(height: 24),

                  // Tarjeta Principal
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text("Validar tipo de servicio", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: azulRey)),
                        const SizedBox(height: 8),
                        Text("Por favor revisa los detalles de tu solicitud antes de confirmar", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),

                        // Alerta/Resumen estilo Bootstrap
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F0), // Fondo crema/naranja suave
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: salmon.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment_turned_in, color: salmon),
                                  const SizedBox(width: 8),
                                  Text("Resumen del servicio", style: TextStyle(fontWeight: FontWeight.bold, color: salmon, fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Grid adaptado para móviles usando Rows y Columns
                              Row(
                                children: [
                                  Expanded(child: _buildResumenItem("Servicio", datos['servicio'] ?? '')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildResumenItem("Equipo", "${datos['equipo']} (${datos['categoria']})")),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildResumenItem("Fecha y hora", "${datos['fechaSeleccionada']} a las ${datos['horaSeleccionada']}"),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildResumenItem("Cliente", datos['nombreCliente'] ?? '')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildResumenItem("Teléfono", datos['telefono'] ?? '')),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildResumenItem("Modelo", datos['modelo']?.isNotEmpty == true ? datos['modelo']! : "No especificado"),
                              const SizedBox(height: 12),
                              _buildResumenItem("Dirección", datos['direccion'] ?? ''),
                              const SizedBox(height: 12),
                              _buildResumenItem("Descripción del problema", datos['descripcion'] ?? ''),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botones de acción
                        Row(
                          children: [
                            // Botón Volver
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cargando ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.grey[300]!, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text("Volver a Editar", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón Confirmar
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cargando ? null : () => _confirmarReserva(datos),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: azulRey,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                child: _cargando
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                                    : const Text("Confirmar Reserva", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
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
    );
  }

  // Widget auxiliar para construir las tarjetitas blancas del resumen
  Widget _buildResumenItem(String titulo, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}