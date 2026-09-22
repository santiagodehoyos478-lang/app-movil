import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

class NuevaClaveScreen extends StatefulWidget {
  const NuevaClaveScreen({super.key});

  @override
  State<NuevaClaveScreen> createState() => _NuevaClaveScreenState();
}

class _NuevaClaveScreenState extends State<NuevaClaveScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final ApiClient _apiClient = ApiClient();
  
  bool _loading = false;
  String? _error;
  String? _success;
  String? _token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. Atraemos el token de seguridad que envió el main.dart desde el Deep Link
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _token = args;
    }
  }

  void _handleActualizarClave() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() => _error = "Por favor, completa ambos campos.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = "Las contraseñas no coinciden. Intenta de nuevo.");
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _error = "La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (_token == null || _token!.isEmpty) {
      setState(() => _error = "Token de seguridad inválido o expirado. Vuelve a solicitar el correo.");
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      // 2. Consumimos la ruta del backend que creamos para actualizar la clave
      final response = await _apiClient.post('/api/actualizar-clave', body: {
        "token": _token,
        "nueva_clave": _passwordController.text.trim(),
      });

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          _success = "¡Contraseña actualizada con éxito! Ya puedes iniciar sesión.";
        });

        // 3. Redirigimos al Login automáticamente después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else {
        setState(() {
          _error = "No se pudo actualizar la contraseña. El enlace pudo haber expirado.";
          _loading = false;
        });
      }

    } catch (e) {
      setState(() {
        _error = "Error de conexión con el servidor.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, size: 50, color: Color(0xFFE57373)),
                const SizedBox(height: 16),
                const Text(
                  'Crear Nueva Contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa tu nueva contraseña para acceder a AR Servicio Técnico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 20),

                if (_error != null) ...[
                  _mensajeCaja(_error!, esError: true),
                  const SizedBox(height: 16),
                ],
                if (_success != null) ...[
                  _mensajeCaja(_success!, esError: false),
                  const SizedBox(height: 16),
                ],

                const Text('Nueva Contraseña *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                const SizedBox(height: 4),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Mínimo 6 caracteres'),
                ),
                const SizedBox(height: 16),

                const Text('Confirmar Contraseña *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                const SizedBox(height: 4),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration('Repite tu contraseña'),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: (_loading || _success != null) ? null : _handleActualizarClave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    _loading ? 'Actualizando...' : 'Guardar Contraseña',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mensajeCaja(String mensaje, {required bool esError}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: esError ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: esError ? Colors.red : const Color(0xFF065F46),
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE57373))),
    );
  }
}