import 'package:flutter/material.dart';
import '../../models/solicitud_model.dart';
import '../../services/solicitud_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SolicitudService _solicitudService = const SolicitudService();
  List<Solicitud> _solicitudes = [];
  bool _cargando = false;
  bool mostrarReservas = false;

  final TextEditingController _searchController =
      TextEditingController();

  String filtroActivo = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _cargando = true);
    try {
      final solicitudes = await _solicitudService.obtenerSolicitudes();
      setState(() {
        _solicitudes = solicitudes;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar solicitudes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: mostrarReservas
                  ? _vistaReservas()
                  : _dashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF245FC9),
            Color(0xFF3478DC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AR SERVICIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'admin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _topButton(
                Icons.refresh,
                _cargarSolicitudes,
              ),
              const SizedBox(width: 9),
              _topButton(
                Icons.logout,
                _cerrarSesion,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _cerrarSesion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cierre de sesión pendiente de conectar'),
      ),
    );
  }

  Widget _dashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
      child: Column(
        children: [
          _statsCard(),
          const SizedBox(height: 12),
          _technicianCard(),
          const SizedBox(height: 12),
          _reservationsCard(),
        ],
      ),
    );
  }

  Widget _statsCard() {
    final total = _solicitudes.length;
    final pendientes =
        _solicitudes.where((s) => s.estado == 'Pendiente').length;
    final enProceso =
        _solicitudes.where((s) => s.estado == 'En Proceso').length;
    final completadas =
        _solicitudes.where((s) => s.estado == 'Completado').length;
    final canceladas =
        _solicitudes.where((s) => s.estado == 'Cancelado').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.15,
        children: [
          _stat(
            Icons.calendar_month,
            total.toString(),
            'Total',
            const Color(0xFF2670DC),
            const Color(0xFFEEF6FF),
          ),
          _stat(
            Icons.access_time,
            pendientes.toString(),
            'Pendientes',
            const Color(0xFFF2A600),
            const Color(0xFFFFF7E6),
          ),
          _stat(
            Icons.build,
            enProceso.toString(),
            'En Proceso',
            const Color(0xFF2670DC),
            const Color(0xFFEEF6FF),
          ),
          _stat(
            Icons.check_circle,
            completadas.toString(),
            'Completadas',
            const Color(0xFF00B878),
            const Color(0xFFEAF3FA),
          ),
          _stat(
            Icons.cancel,
            canceladas.toString(),
            'Canceladas',
            const Color(0xFFFF4747),
            const Color(0xFFFFF0F0),
          ),
          _stat(
            Icons.handyman,
            total.toString(),
            'Servicios',
            const Color(0xFF5266C8),
            const Color(0xFFEEF0FF),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    IconData icon,
    String number,
    String text,
    Color iconColor,
    Color iconBackground,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFEDF0F4),
          ),
          bottom: BorderSide(
            color: Color(0xFFEDF0F4),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            text,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF7B8492),
            ),
          ),
        ],
      ),
    );
  }

  Widget _technicianCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1760CE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fabio Alexander Rojas Lara',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26364A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Técnico especializado',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF7D8794),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone,
                  size: 13,
                  color: Color(0xFF16A05D),
                ),
                SizedBox(width: 4),
                Text(
                  '3005635595',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A05D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reservationsCard() {
    final recientes = _solicitudes.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEDF0F4),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reservas Recientes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26364A),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      mostrarReservas = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF1458BB),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: Color(0xFF1458BB),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_cargando)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recientes.isEmpty)
            const SizedBox(
              height: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 31,
                    color: Color(0xFFDCE1E8),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'No hay reservas aún',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9DA6B2),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recientes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = recientes[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    s.nombreCliente,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${s.equipo} - ${s.marca}',
                    style: const TextStyle(fontSize: 9),
                  ),
                  trailing: Text(
                    s.estado,
                    style: TextStyle(
                      fontSize: 8,
                      color: _getEstadoColor(s.estado),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFF2A600);
      case 'En Proceso':
        return const Color(0xFF2670DC);
      case 'Completado':
        return const Color(0xFF00B878);
      case 'Cancelado':
        return const Color(0xFFFF4747);
      default:
        return Colors.grey;
    }
  }

  Widget _vistaReservas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  mostrarReservas = false;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 15,
                      color: Color(0xFF1458BB),
                    ),
                    Text(
                      'Volver al panel',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1458BB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFB8C9E8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.search,
                  size: 17,
                  color: Color(0xFF9CA7B5),
                ),
                hintText: 'Buscar cliente, servicio...',
                hintStyle: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8D96A3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filter('Todos'),
                _filter('Pendiente'),
                _filter('En Proceso'),
                _filter('Completado'),
                _filter('Cancelado'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _listaCompletaReservas(),
        ],
      ),
    );
  }

  Widget _listaCompletaReservas() {
    final filtradas = _solicitudes.where((s) {
      final matchesFiltro =
          filtroActivo == 'Todos' || s.estado == filtroActivo;
      final matchesSearch = s.nombreCliente
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          s.equipo
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesFiltro && matchesSearch;
    }).toList();

    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filtradas.isEmpty) {
      return Container(
        width: double.infinity,
        height: 153,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 34,
              color: Color(0xFFE1E5EA),
            ),
            SizedBox(height: 8),
            Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8F99A7),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Prueba con otros filtros',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFAAB2BD),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtradas.length,
      itemBuilder: (context, index) {
        final s = filtradas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 5,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.nombreCliente,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  s.fecha,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${s.equipo} - ${s.marca}',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  s.direccion,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(s.estado).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.estado,
                        style: TextStyle(
                          fontSize: 8,
                          color: _getEstadoColor(s.estado),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (val) {
                if (val == 'eliminar') {
                  _confirmarEliminacion(s.id);
                } else {
                  _cambiarEstado(s.id, val);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'Pendiente',
                  child: Text('Marcar como Pendiente', style: TextStyle(fontSize: 10)),
                ),
                const PopupMenuItem(
                  value: 'En Proceso',
                  child: Text('Marcar como En Proceso', style: TextStyle(fontSize: 10)),
                ),
                const PopupMenuItem(
                  value: 'Completado',
                  child: Text('Marcar como Completado', style: TextStyle(fontSize: 10)),
                ),
                const PopupMenuItem(
                  value: 'Cancelado',
                  child: Text('Marcar como Cancelado', style: TextStyle(fontSize: 10)),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Text(
                    'Eliminar solicitud',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    try {
      await _solicitudService.actualizarSolicitud(id, estado: nuevoEstado);
      _cargarSolicitudes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _confirmarEliminacion(int id) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar solicitud?', style: TextStyle(fontSize: 14)),
        content: const Text('Esta acción no se puede deshacer.', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _solicitudService.eliminarSolicitud(id);
        _cargarSolicitudes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud eliminada')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  Widget _filter(String text) {
    final bool activo = filtroActivo == text;

    final count = text == 'Todos'
        ? _solicitudes.length
        : _solicitudes.where((s) => s.estado == text).length;

    final label = '$text ($count)';

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: InkWell(
        onTap: () {
          setState(() {
            filtroActivo = text;
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: activo ? const Color(0xFFF5F8FC) : Colors.white,
            border: Border.all(
              color: activo ? const Color(0xFF245FC9) : const Color(0xFFDCE2E9),
              width: activo ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: activo ? const Color(0xFF245FC9) : const Color(0xFF394454),
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
