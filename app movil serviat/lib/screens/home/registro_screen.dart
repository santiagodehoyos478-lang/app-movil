import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombre1Controller = TextEditingController();
  final _nombre2Controller = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _direccionController = TextEditingController();
  final _emailController = TextEditingController();
  final _claveController = TextEditingController();

  String _tipoDocumento = 'CC';
  String _rol = '1';
  bool _loading = false;

  void _handleSubmit() async {
    if (_claveController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La clave debe tener al menos 8 caracteres.')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro Exitoso!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // modal-overlay
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white, // ventana-registro-grande
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BOTÓN CERRAR
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF999999)),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    ),
                  ),

                  const Text(
                    'Crear Cuenta en ServiAT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NOMBRES (flex-row)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nombre1Controller,
                          decoration: _inputDecoration('Primer Nombre*'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _nombre2Controller,
                          decoration: _inputDecoration('Segundo Nombre'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // APELLIDOS (flex-row)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apellido1Controller,
                          decoration: _inputDecoration('Primer Apellido*'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _apellido2Controller,
                          decoration: _inputDecoration('Segundo Apellido'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TIPO DOC Y ROL (flex-row)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tipoDocumento,
                          decoration: _inputDecoration(''),
                          items: const [
                            DropdownMenuItem(value: 'CC', child: Text('C.C.')),
                            DropdownMenuItem(value: 'TI', child: Text('T.I.')),
                            DropdownMenuItem(value: 'CE', child: Text('C.E.')),
                          ],
                          onChanged: (val) => setState(() => _tipoDocumento = val!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _rol,
                          decoration: _inputDecoration('').copyWith(
                            fillColor: const Color(0xFFFFF4F4),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE57373)),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('Soy Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: '2', child: Text('Soy Técnico', style: TextStyle(fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: '3', child: Text('Soy Administrador', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          onChanged: (val) => setState(() => _rol = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DOCUMENTO Y TELÉFONO (flex-row)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _documentoController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Número Documento*'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Teléfono'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FECHA Y DIRECCIÓN (flex-row)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 2),
                              child: Text(
                                'Fecha Nacimiento*',
                                style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
                              ),
                            ),
                            TextField(
                              controller: _fechaNacController,
                              readOnly: true,
                              decoration: _inputDecoration('AAAA-MM-DD').copyWith(
                                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                              ),
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1930),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _fechaNacController.text = picked.toString().split(' ')[0];
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _direccionController,
                          decoration: _inputDecoration('Dirección'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // EMAIL
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Correo Electrónico*'),
                  ),
                  const SizedBox(height: 12),

                  // PASSWORD
                  TextField(
                    controller: _claveController,
                    obscureText: true,
                    decoration: _inputDecoration('Contraseña (mín. 8)*'),
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN REGISTRO
                  ElevatedButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _loading ? 'Registrando...' : 'Registrarse',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // LOGIN LINK
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE57373),
                        fontSize: 13,
                      ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE57373)),
      ),
    );
  }
}