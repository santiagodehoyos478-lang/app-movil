import 'package:flutter/material.dart';
import 'widgets/infoFormulario.dart';
import 'screens/home/login_screen.dart';
import 'screens/home/registro_screen.dart';
import 'screens/home/Formulario.dart';
import 'screens/home/ValidarServicio.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_screeeen_dana.dart';
import 'screens/home/index.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Servicio Técnico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE57373)),
        useMaterial3: true,
      ),
      // Pantalla inicial al abrir la aplicación
      initialRoute: '/',
      
      // 2. Registro de rutas con los nombres exactos de tus clases
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/infoFormulario': (context)=> const InformacionPaso1(),
        '/Formulario': (context) => const Formulario(),
        '/ValidarInformacion': (context) => const ValidarInformacion(),  
        '/dana': (context) => const HomeDanaScreen(),
        '/dashboard': (context) => const HomeScreen(),         
      },
    );
  }
}