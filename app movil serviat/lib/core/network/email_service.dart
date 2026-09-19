import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../constants/app_credenciales.dart';

class EmailService {
  
  Future<void> enviarCredenciales(String recipientEmail, String password, int rolId) async {
    // 1. Configurar servidor SMTP para Gmail
    final smtpServer = gmail(AppConstants.smtpUser, AppConstants.smtpPass);

    String rolNombre = (rolId == 3) ? "Administrador" : "Técnico";

    // 2. Crear el mensaje
    final message = Message()
      ..from = Address(AppConstants.smtpUser, 'AR Servicio Técnico')
      ..recipients.add(recipientEmail)
      ..subject = 'Bienvenido a AR Servicio Técnico - Tus Credenciales'
      ..html = """
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
          <h2 style="color: #2448B5; text-align: center;">¡Bienvenido al Equipo!</h2>
          <p>Hola,</p>
          <p>Has sido registrado como <strong>$rolNombre</strong> en la plataforma de <strong>AR Servicio Técnico</strong>. A continuación, encontrarás tus credenciales para acceder a la aplicación:</p>
          
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p style="margin: 5px 0;"><strong>Usuario:</strong> $recipientEmail</p>
            <p style="margin: 5px 0;"><strong>Contraseña:</strong> $password</p>
          </div>

          <p>Por seguridad, te recomendamos cambiar tu contraseña una vez que hayas iniciado sesión por primera vez.</p>
          
          <div style="text-align: center; margin-top: 30px;">
            <p style="font-size: 12px; color: #999;">© 2026 AR Servicio Técnico. Todos los derechos reservados.</p>
          </div>
        </div>
      """;

    try {
      print("📧 [EMAIL] Intentando enviar correo a: $recipientEmail...");
      final sendReport = await send(message, smtpServer);
      print('✅ [EMAIL] Correo enviado con éxito: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('❌ [EMAIL] Error al enviar correo: $e');
      for (var p in e.problems) {
        print('🔍 Problema: ${p.code}: ${p.msg}');
      }
    }
  }
}
