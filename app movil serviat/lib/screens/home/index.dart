import 'package:flutter/material.dart';
import 'package:app_movil_serviat/screens/home/registro_screen.dart';
import '../../widgets/infoFormulario.dart';
import 'Formulario.dart';
class ServiatApp extends StatelessWidget {
  const ServiatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Servicio Técnico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2448B5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),

        initialRoute: '/',

        // 2. Creamos el mapa de rutas
        routes: {
          '/': (context) => const HomePage(),
          '/infoFormulario': (context) => const InformacionPaso1(),
          '/registro_screen': (context) => const RegistroScreen(),
          '/Formulario': (context) => const Formulario(),
        },
      );
    }
}

//clase para el menu
class CustomMenuDrawer extends StatelessWidget {
  const CustomMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea( // evita que el menu se monte sobre la barra de estado del celular
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AR SERVICIO TÉCNICO',
                    style: TextStyle(
                      color: Color(0xFFE06B6B),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // opciones
              _buildMenuItem(
                'Inicio',
                isPrimary: true,
                onTap: () => Navigator.pushNamed(context, '/'), // O la ruta principal que prefieras
              ),

        const SizedBox(height: 10),
        _buildMenuItem(
          'Acerca de Nosotros',
          isPrimary: false,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          'Reservar',
          isPrimary: false,
          onTap: () => Navigator.pushNamed(context, '/infoFormulario'),
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          'Registrarse',
          isPrimary: false,
          onTap: () => Navigator.pushNamed(context, '/registro_screen'),
        ),
            ],
          ),
        ),
      ),
    );
  }

  //funcion  para construir los botones
  Widget _buildMenuItem(String title, {required bool isPrimary,required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, // Aquí es donde Flutter ejecuta la navegación que le mandamos arriba
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE06B6B) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF4A4A4A),
            fontSize: 15,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para la sección de tarjetas
      appBar: AppBar(
        title: const Text(
          'AR SERVICIO TÉCNICO',
          style: TextStyle(
            color: Color(0xFFE06B6B),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const CustomMenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SECCIÓN AZUL (HEADER)
            Container(
              width: double.infinity,
              color: const Color(0xFF2448B5),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/logoser.png',
                      width: 250,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '⭐ SERVICIO PREMIUM 5 ESTRELLAS',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Reparación Profesional de Electrodomésticos',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Servicio técnico especializado en reparación de electrodomésticos industriales. ¡Rápido, eficiente y con garantía total!',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4CEB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Conoce nuestros servicios', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text('Historial', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 12)),
                            Text('3005635595', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // seccion de las tarjetas
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildServiceCard(
                    context,
                    title: 'Reparación de electrodomésticos',
                    subtitle: 'Servicio especializado',
                    buttonText: 'Agendar servicio',
                    imagePath: 'assets/images/lavadora.jpg', // Cambia por tu imagen
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Servicio Especializado',
                    subtitle: 'Técnicos profesionales',
                    buttonText: 'Consultar ahora',
                    imagePath: 'assets/images/industrial.jpg', // Cambia por tu imagen
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Equipos Industriales',
                    subtitle: 'Alta capacidad',
                    buttonText: 'Ver servicios',
                    imagePath: 'assets/images/imagen3.jpg', // Cambia por tu imagen
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Expertos en Reparación',
                    style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Profesionales dedicados a brindar el mejor servicio de reparación',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7D7D7D), fontSize: 15),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4CEB),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Solicitar Servicio Ahora',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widgets para las tarjetas
  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/formulario');
              },
              child: Text(buttonText, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
