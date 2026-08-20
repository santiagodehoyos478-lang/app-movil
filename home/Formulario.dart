import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  State<Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();

  // Estado: equivalente a useState en React
  String _appliance = "";
  String _horaSeleccionada = "";
  DateTime _fechaSeleccionada = DateTime.now();

  // Datos del formulario
  final Map<String, String> _datosValidar = {
    "equipo": "",
    "categoria": "Industrial",
    "nombreCliente": "",
    "apellidoCliente": "",
    "gmail": "",
    "telefono": "",
    "direccion": "",
    "descripcion": "",
    "modelo": "",
  };

  final List<String> horarios = [
    "07:00 AM", "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM",
    "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM", "05:00 PM", "06:00 PM"
  ];

  final List<DateTime> reservado = [
    DateTime(2026, 4, 25),
    DateTime(2026, 4, 31),
  ];

  // Lógica para bloquear fechas (Domingos y fechas reservadas)
  bool _bloquearFechas(DateTime day) {
    if (day.weekday == DateTime.sunday) return false; // Deshabilita domingos
    for (var res in reservado) {
      if (day.year == res.year && day.month == res.month && day.day == res.day) {
        return false; // Deshabilita la fecha si está reservada
      }
    }
    return true; // true significa que la fecha SE PUEDE seleccionar
  }

  // Equivalente a manejarEnvio
  Future<void> _manejarEnvio() async {
    // Valida que los campos requeridos estén llenos
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_appliance.isEmpty || _horaSeleccionada.isEmpty) {
      _mostrarAlerta("Paso faltante", "Por favor selecciona el tipo de servicio y la hora.", false);
      return;
    }

    try {
      // Equivalente a localStorage
      final prefs = await SharedPreferences.getInstance();
      final userGuardado = prefs.getString("user");



      // Simular el SweetAlert de éxito
      await _mostrarAlerta("Datos validados", "Redirigiendo a la confirmación final...", true);

      // Equivalente a navigate("/ValidarInformacion", { state: {...} })
      if (!mounted) return;

      final Map<String, dynamic> payload = {
        ..._datosValidar,
        "servicio": _appliance,
        "fechaSeleccionada": _fechaSeleccionada.toIso8601String().split('T')[0],
        "horaSeleccionada": _horaSeleccionada,
      };

      Navigator.pushNamed(
        context,
        '/ValidarInformacion',
        arguments: payload,
      );

    } catch (error) {
      _mostrarAlerta("Error al guardar", error.toString(), false);
    }
  }

  // Método auxiliar para reemplazar SweetAlert2
  Future<void> _mostrarAlerta(String titulo, String mensaje, bool exito) async {
    const Color azulRey = Color(0xFF003366);
    return showDialog(
      context: context,
      barrierDismissible: !exito,
      builder: (context) {
        if (exito) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
        }
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: azulRey.withOpacity(0.1), width: 1),
          ),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: azulRey)),
          content: Text(mensaje, style: const TextStyle(color: azulRey)),
          actions: exito ? [] : [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido", style: TextStyle(color: azulRey, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azulRey = Color(0xFF0D6EFD);
    const Color salmon = Color(0xFFFF8C69);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: azulRey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Center(
                            child: Text(
                              "Ingresa tu información",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: azulRey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          _buildTextField("Nombres", "Ingresa tu nombre", "nombreCliente"),
                          const SizedBox(height: 16),
                          _buildTextField("Apellidos", "Ingresa tu apellido", "apellidoCliente"),
                          const SizedBox(height: 16),
                          _buildTextField("Nombre del equipo", "Ingresa nombre del equipo", "equipo"),
                          const SizedBox(height: 16),

                          const Text("Categoría del equipo", style: TextStyle(fontWeight: FontWeight.w600, color: azulRey)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _datosValidar["categoria"],
                            decoration: _inputDecoration(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: azulRey),
                            items: ["Industrial", "Doméstico"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: azulRey)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _datosValidar["categoria"] = val!),
                          ),
                          const SizedBox(height: 24),

                          const Text("Tipo de servicio", style: TextStyle(fontWeight: FontWeight.w600, color: azulRey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildServiceCard("Reparación", Icons.build_circle_outlined)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildServiceCard("Instalación", Icons.settings_input_component_outlined)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildTextField("Descripción del problema", "Escribe la descripción del servicio", "descripcion", maxLines: 3),
                          const SizedBox(height: 16),
                          _buildTextField("Modelo del equipo", "Ingresa modelo del equipo (si lo conoce)", "modelo", isRequired: false),
                          const SizedBox(height: 16),
                          _buildTextField("Teléfono", "Ingresa numero celular para contactar", "telefono", keyboardType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField("Correo Electrónico", "Ingresa correo electrónico", "gmail", keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField("Dirección", "Dirección del servicio realizar", "direccion"),
                          const SizedBox(height: 24),

                          const Center(
                            child: Text("Seleccione la fecha", style: TextStyle(fontWeight: FontWeight.w600, color: azulRey)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: azulRey.withOpacity(0.2)),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: salmon,
                                  onPrimary: Colors.white,
                                  onSurface: azulRey,
                                ),
                              ),
                              child: CalendarDatePicker(
                                initialDate: _fechaSeleccionada,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                selectableDayPredicate: _bloquearFechas,
                                onDateChanged: (date) => setState(() => _fechaSeleccionada = date),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              "Fecha seleccionada: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}",
                              style: const TextStyle(color: salmon, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Card del Técnico
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: azulRey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: azulRey.withOpacity(0.1)),
                            ),
                            child: const Column(
                              children: [
                                Text("TÉCNICO DISPONIBLE", style: TextStyle(color: azulRey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                                SizedBox(height: 8),
                                Text("Nombre:", style: TextStyle(color: azulRey, fontSize: 12)),
                                Text("Fabio Alexander Rojas Lara", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: azulRey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Center(
                            child: Text("Seleccione la hora a realizar el servicio", style: TextStyle(fontWeight: FontWeight.w600, color: azulRey)),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: horarios.length,
                            itemBuilder: (context, index) {
                              final h = horarios[index];
                              final isSelected = _horaSeleccionada == h;
                              return InkWell(
                                onTap: () => setState(() => _horaSeleccionada = h),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? salmon : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSelected ? salmon : azulRey.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    h,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : azulRey,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Botón Enviar
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [azulRey, Color(0xFF004080)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: azulRey.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _manejarEnvio,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "Enviar Solicitud",

                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [azulRey, Color(0xFF001A33)],
                ),
              ),
              child: Column(
                children: [
                  const Text("AR SERVICIO TÉCNICO", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    "Servicios de reparaciones y instalaciones de electrodomésticos en el sector HORECA. Especialistas en equipos industriales y domésticos.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("WhatsApp: 3005635595", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    "© 2026 AR SERVICIO TÉCNICO - Todos los derechos reservados - Fabio Alexander Rojas Lara",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ACTUALIZADOS ---

  Widget _buildTextField(String label, String hint, String fieldKey, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool isRequired = true}) {
    const Color azulRey = Color(0xFF0D6EFD);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: azulRey)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: _inputDecoration(hint: hint),
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: azulRey),
          validator: isRequired ? (value) => value == null || value.isEmpty ? 'Campo requerido' : null : null,
          onSaved: (value) => _datosValidar[fieldKey] = value ?? '',
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    const Color azulRey = Color(0xFF0D6EFD);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: azulRey, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }

  Widget _buildServiceCard(String text, IconData icon) {
    const Color azulRey = Color(0xFF0D6EFD);
    const Color salmon = Color(0xFFFF8C69);
    final isSelected = _appliance == text;
    return InkWell(
      onTap: () => setState(() => _appliance = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? salmon : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: salmon.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? salmon : azulRey.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? salmon : azulRey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
