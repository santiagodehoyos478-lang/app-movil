import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'equipos_list_screen.dart';
import 'salones_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DashboardScreen(),
    EquiposListScreen(
      salonId: 1,
      salonNombre: 'Salón 317 (30 PCs)',
    ),
    SalonesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: Colors.blueAccent.withOpacity(0.15),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.computer_outlined),
              selectedIcon: Icon(Icons.computer, color: Colors.blueAccent),
              label: 'Equipos',
            ),
            NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined),
              selectedIcon: Icon(Icons.meeting_room, color: Colors.blueAccent),
              label: 'Salones',
            ),
          ],
        ),
      ),
    );
  }
}