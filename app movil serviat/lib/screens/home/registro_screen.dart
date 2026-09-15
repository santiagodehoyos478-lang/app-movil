import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app_movil_serviat/core/theme/estilo_registro.dart';
import '../../core/network/api_solicitud.dart';
import 'package:app_movil_serviat/services/registro_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});


  static const String _baseUrl='http//192.168.40.29:8080';

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  
  // 1. LÓGICA DE NEGOCIO Y ESTADOS
  
  final _formKey = GlobalKey<FormState>();

  // Controladores
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

  // Variables de Estado
  String _tipoDocumento = 'CC';
  String _rol = '1';
  bool _loading = false;
  bool _obscurePassword = true;

  // Expresiones regulares
  final RegExp _letrasRegExp = RegExp(r'^[a-zA-ZÀ-ÿ\u00f1\u00d1\s]+$');
  final RegExp _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _nombre1Controller.dispose();
    _nombre2Controller.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _fechaNacController.dispose();
    _emailController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  // --- AQUÍ ESTÁ LA LÓGICA CORREGIDA ---
  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    
    try {
      // 1. Recolectamos todos los datos del formulario.
      final Map<String, dynamic> userData = {
        'nombre_1': _nombre1Controller.text.trim(),
        'nombre_2': _nombre2Controller.text.trim(),
        'apellido_1': _apellido1Controller.text.trim(),
        'apellido_2': _apellido2Controller.text.trim(),
        'tipo_documento': _tipoDocumento, 
        'documento': _documentoController.text.trim(), 
        'telefono': _telefonoController.text.trim(),
        'fecha_nacimiento': _fechaNacController.text.trim(),
        'email': _emailController.text.trim(),
        'clave': _claveController.text.trim(), 
        'rol': int.tryParse(_rol) ?? 1, 
      };

      // 2. Llamamos al servicio
      final registroService = RegistroService();
      bool exito = await registroService.registrarUsuario(userData);

      // 3. Mostramos el resultado
      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro Exitoso! Bienvenido.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrar. Revisa la consola.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Si ocurre un error fatal al armar los datos, lo atrapamos aquí
      print("🚨 Error atrapado en la pantalla de registro: $e");
    } finally {
      // 4. ESTO ES LO MÁS IMPORTANTE: 
      // El bloque "finally" SIEMPRE se ejecuta, haya error o no.
      // Así aseguramos que el botón jamás se quede cargando infinitamente.
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // 2. INTERFAZ GRÁFICA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: EstiloRegistro.boxDecorationVentana(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBotonCerrar(),
                  _buildTitulo(),
                  const SizedBox(height: 20),
                  _buildNombres(),
                  const SizedBox(height: 12),
                  _buildApellidos(),
                  const SizedBox(height: 12),
                  _buildTipoDocumentoYRol(),
                  const SizedBox(height: 12),
                  _buildDocumentoYTelefono(),
                  const SizedBox(height: 12),
                  _buildFechaYDireccion(),
                  const SizedBox(height: 12),
                  _buildEmail(),
                  const SizedBox(height: 12),
                  _buildPassword(),
                  const SizedBox(height: 16),
                  _buildBotonRegistro(),
                  const SizedBox(height: 12),
                  _buildEnlaceLogin(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 3. WIDGETS MODULARES (Partes del formulario)

  Widget _buildBotonCerrar() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF999999)),
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      ),
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Crear Cuenta en ServiAT',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildNombres() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _nombre1Controller,
            decoration: EstiloRegistro.inputDecoration('Primer Nombre*'),
            validator: (val) => _validarLetras(val, requerido: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _nombre2Controller,
            decoration: EstiloRegistro.inputDecoration('Segundo Nombre'),
            validator: (val) => _validarLetras(val, requerido: false),
          ),
        ),
      ],
    );
  }

  Widget _buildApellidos() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _apellido1Controller,
            decoration: EstiloRegistro.inputDecoration('Primer Apellido*'),
            validator: (val) => _validarLetras(val, requerido: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _apellido2Controller,
            decoration: EstiloRegistro.inputDecoration('Segundo Apellido'),
            validator: (val) => _validarLetras(val, requerido: false),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoDocumentoYRol() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _tipoDocumento,
            decoration: EstiloRegistro.inputDecoration(''),
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
            initialValue: _rol,
            decoration: EstiloRegistro.inputDecoration('').copyWith(
              fillColor: const Color(0xFFFFF4F4),
              filled: true,
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
    );
  }

  Widget _buildDocumentoYTelefono() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _documentoController,
            keyboardType: TextInputType.number,
            decoration: EstiloRegistro.inputDecoration('Número Documento*'),
            validator: _validarNumeros,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: EstiloRegistro.inputDecoration('Teléfono*'),
            validator: _validarNumeros,
          ),
        ),
      ],
    );
  }

  Widget _buildFechaYDireccion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 2),
                child: Text('Fecha Nacimiento*', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
              ),
              TextFormField(
                controller: _fechaNacController,
                readOnly: true,
                decoration: EstiloRegistro.inputDecoration('AAAA-MM-DD').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 15),
              TextFormField(
                controller: _direccionController,
                decoration: EstiloRegistro.inputDecoration('Dirección*'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: EstiloRegistro.inputDecoration('Correo Electrónico*'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Requerido';
        if (!_emailRegExp.hasMatch(value)) return 'Correo inválido';
        return null;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: _claveController,
      obscureText: _obscurePassword,
      decoration: EstiloRegistro.inputDecoration('Contraseña (mín. 8)*').copyWith(
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requerida';
        if (value.length < 8) return 'Mínimo 8 caracteres';
        return null;
      },
    );
  }

  Widget _buildBotonRegistro() {
    return ElevatedButton(
      onPressed: _loading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE57373),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        _loading ? 'Registrando...' : 'Registrarse',
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEnlaceLogin() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      child: const Text(
        '¿Ya tienes cuenta? Inicia sesión',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFE57373), fontSize: 13),
      ),
    );
  }

  String? _validarLetras(String? value, {required bool requerido}) {
    if (requerido && (value == null || value.trim().isEmpty)) return 'Requerido';
    if (value != null && value.trim().isNotEmpty && !_letrasRegExp.hasMatch(value)) return 'Solo letras';
    return null;
  }

  String? _validarNumeros(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    if (int.tryParse(value.trim()) == null) return 'Solo números';
    return null;
  }
}