import 'package:flutter/material.dart';

class AppConstants {
AppConstants._();

// Nombre de la aplicación
static const String appName = 'ServiAT';

// Nombre del usuario/rol
static const String technicianTitle = 'Técnico';

// Colores principales
static const Color primaryColor = Color(0xFF1976D2);
static const Color secondaryColor = Color(0xFF42A5F5);

static const Color backgroundColor = Color(0xFFF5F7FA);

// Estados de las solicitudes
static const String pendiente = 'Pendiente';
static const String enProceso = 'En proceso';
static const String completado = 'Completado';
static const String cancelado = 'Cancelado';

// URL de la API
static const String apiBaseUrl = 'http://192.168.0.15:3001/api';
}