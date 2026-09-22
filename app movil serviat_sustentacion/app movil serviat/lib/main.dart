import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:app_links/app_links.dart'; // 

import 'widgets/infoFormulario.dart';
import 'screens/home/login_screen.dart';
import 'screens/home/registro_screen.dart';
import 'screens/home/Formulario.dart';
import 'screens/home/ValidarServicio.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_screeeen_dana.dart';
import 'screens/home/index.dart';
import 'screens/home/nueva_clave_screen.dart'; // 
import 'core/constants/app_credenciales.dart';
import 'screens/home/ServicioConfirmado.dart';

//  Llave global para navegar sin necesidad de tener el "context" a mano
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.publishable_key,
  );

  runApp(const MiApp());
}

class MiApp extends StatefulWidget {
  const MiApp({super.key});

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // 📡 Configuración para "escuchar" cuando abren la app desde el correo
  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      _procesarEnlace(uri);
    });
  }

  void _procesarEnlace(Uri uri) {
    // Verificamos si el enlace contiene el token de recuperación de Supabase
    if (uri.fragment.contains('access_token')) {
      final fragmentString = uri.fragment;
      
      // Extraemos el token limpio
      final paramsUri = Uri.parse("http://localhost/?$fragmentString");
      final accessToken = paramsUri.queryParameters['access_token'];

      if (accessToken != null) {
        // Redirigimos a la pantalla de nueva clave y le pasamos el token de seguridad
        navigatorKey.currentState?.pushNamed(
          '/nueva-clave', 
          arguments: accessToken,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Servicio Técnico',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 👈 Asignamos la llave global aquí
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE57373)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      
      // Registro de rutas, incluyendo la nueva ruta de recuperación
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/infoFormulario': (context)=> const InformacionPaso1(),
        '/Formulario': (context) => const Formulario(),
        '/ValidarInformacion': (context) => const ValidarInformacion(),
        '/ServicioConfirmado': (context) => ServicioConfirmado(),
        '/dana': (context) => const HomeDanaScreen(),
        '/dashboard': (context) => const HomeScreen(),         
        '/nueva-clave': (context) => const NuevaClaveScreen(), // 👈 Ruta agregada
      },
    );
  }
}