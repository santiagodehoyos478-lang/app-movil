import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/products_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'ServiAT',

      theme: AppTheme.lightTheme,

      initialRoute: '/',

      routes: {

        '/': (context) =>
        const HomeScreen(),

        '/products': (context) =>
        const ProductsScreen(),
      },
    );
  }
}