import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';



class EquiposRealTiempo extends StatefulWidget {
  const EquiposRealTiempo({Key? key}) : super(key: key);

  @override
  State<EquiposRealTiempo> createState()=> _EquiposRealTiempoState();
}

class _EquiposRealTiempoState extends State<EquiposRealTiempo>{
  final _equipos=Supabase.instance.client
      .from('equipos')
      .stream(primaryKey:['id']);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitos de equipos'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _equipos,
        builder: (context,snapshot) {

          //logica de conexion
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return Center(child: Text('Ocurrio un error: ${snapshot.error}'));
          }
          if(!snapshot.hasData||snapshot.data!.isEmpty){
            return const Center(child: Text('No hya equipos registrados'));
          }

          final equipos=snapshot.data!;
          return ListView.builder(
            itemCount: equipos.length,
            itemBuilder: (context,index){
              final equipo=equipos[index];

              final codigo=equipo['codigo']??'Sin codigo';
              final estado=equipo['estado']??false;
              final observacion=equipo['observacion']??'';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: estado ? Colors.green: Colors.red,
                  child: Icon(
                    estado ? Icons.check:Icons.build,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Equipo: $codigo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  observacion.isNotEmpty ? observacion: 'sin observacion',
                  style: const TextStyle(color:Colors.grey),
                ),
              );
            }
          );
        },

      ),
    );
  }
}





void main() {
  runApp(const MonitorApp());
}



class MonitorApp extends StatelessWidget {
  const MonitorApp({super.key});




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Equipos',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080A0C),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'monospace'),
      ),
      home: const MonitorDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ── MODELOS Y METADATOS ──

enum PcStatus { ok, broken, maintenance, offline }

class Computer {
  final int id;
  final String label;
  PcStatus status;
  String since;
  String note;
  final int row;
  final int seat;

  Computer({
    required this.id,
    required this.label,
    required this.status,
    required this.since,
    required this.note,
    required this.row,
    required this.seat,
  });
}

class StatusMeta {
  final String label;
  final Color color;
  final Color bg;
  final Color border;

  StatusMeta(this.label, this.color, this.bg, this.border);
}

final Map<PcStatus, StatusMeta> statusMeta = {
  PcStatus.ok: StatusMeta('OPERATIVO', const Color(0xFF00E87A), const Color(0xFF00E87A).withOpacity(0.07), const Color(0xFF00E87A).withOpacity(0.3)),
  PcStatus.broken: StatusMeta('AVERIADO', const Color(0xFFFF2D55), const Color(0xFFFF2D55).withOpacity(0.09), const Color(0xFFFF2D55).withOpacity(0.4)),
  PcStatus.maintenance: StatusMeta('MANTENIM.', const Color(0xFFF5A623), const Color(0xFFF5A623).withOpacity(0.07), const Color(0xFFF5A623).withOpacity(0.35)),
  PcStatus.offline: StatusMeta('APAGADO', const Color(0xFF5A6478), const Color(0xFF3A3F4A).withOpacity(0.18), const Color(0xFF3A3F4A).withOpacity(0.35)),
};

// ── PANTALLA PRINCIPAL ──

class MonitorDashboard extends StatefulWidget {
  const MonitorDashboard({super.key});

  @override
  State<MonitorDashboard> createState() => _MonitorDashboardState();
}

class _MonitorDashboardState extends State<MonitorDashboard> {
  late List<Computer> computers;
  PcStatus? currentFilter; // null significa "Todos"
  bool isGrid = true;
  late Timer _timer;
  String timeString = _getTimeString();

  @override
  void initState() {
    super.initState();
    computers = _buildComputers();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() => timeString = _getTimeString());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static String _getTimeString() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  List<Computer> _buildComputers() {
    List<Map<String, dynamic>> base = [
      {'id': 1, 'status': PcStatus.ok, 'note': ''},
      {'id': 2, 'status': PcStatus.ok, 'note': ''},
      {'id': 3, 'status': PcStatus.broken, 'note': 'No enciende'},
      {'id': 6, 'status': PcStatus.maintenance, 'note': 'Actualiz. SO'},
      {'id': 10, 'status': PcStatus.broken, 'note': 'Teclado dañado'},
      {'id': 13, 'status': PcStatus.offline, 'note': ''},
      {'id': 17, 'status': PcStatus.maintenance, 'note': 'Revisión disco'},
      {'id': 20, 'status': PcStatus.broken, 'note': 'Pantalla azul'},
      {'id': 25, 'status': PcStatus.offline, 'note': ''},
      {'id': 29, 'status': PcStatus.maintenance, 'note': 'Sin disco duro'},
    ];

    return List.generate(30, (index) {
      int id = index + 1;
      var override = base.where((b) => b['id'] == id).firstOrNull;
      PcStatus status = override != null ? override['status'] : PcStatus.ok;
      String note = override != null ? override['note'] : '';

      String since = status == PcStatus.ok ? "08:00" : status == PcStatus.offline ? "—" : "0${8 + (id / 5).floor()}:${((id * 7) % 60).toString().padLeft(2, '0')}";

      return Computer(
        id: id,
        label: 'PC-${id.toString().padLeft(2, '0')}',
        status: status,
        since: since,
        note: note,
        row: (id / 6).ceil(),
        seat: ((id - 1) % 6) + 1,
      );
    });
  }

  // ── GETTERS (Equivalentes a useMemo) ──
  int get countOk => computers.where((c) => c.status == PcStatus.ok).length;
  int get countBroken => computers.where((c) => c.status == PcStatus.broken).length;
  int get countMaint => computers.where((c) => c.status == PcStatus.maintenance).length;
  int get countOff => computers.where((c) => c.status == PcStatus.offline).length;

  List<Computer> get filteredComputers {
    if (currentFilter == null) {
      List<Computer> list = List.from(computers);
      List<PcStatus> order = [PcStatus.broken, PcStatus.maintenance, PcStatus.offline, PcStatus.ok];
      list.sort((a, b) => order.indexOf(a.status).compareTo(order.indexOf(b.status)));
      return list;
    }
    return computers.where((c) => c.status == currentFilter).toList();
  }

  void _updateComputer(int id, PcStatus newStatus, String newNote) {
    setState(() {
      final index = computers.indexWhere((c) => c.id == id);
      if (index != -1) {
        computers[index].status = newStatus;
        computers[index].note = newNote;
        computers[index].since = _getTimeString();
      }
    });
  }

  void _openDetailSheet(Computer computer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailSheet(
        computer: computer,
        onSave: (status, note) {
          _updateComputer(computer.id, status, note);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int healthPct = ((countOk / computers.length) * 100).round();
    Color healthColor = healthPct >= 90 ? const Color(0xFF00E87A) : healthPct >= 70 ? const Color(0xFFF5A623) : const Color(0xFFFF2D55);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0D12),
                border: Border(bottom: BorderSide(color: Color(0xFF1E2430))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('◉ EN VIVO  SALÓN 317', style: TextStyle(color: Color(0xFF00E87A), fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('Monitor de Equipos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Text(timeString, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip('OPERATIVOS', countOk, statusMeta[PcStatus.ok]!.color),
                      _StatChip('AVERIADOS', countBroken, statusMeta[PcStatus.broken]!.color),
                      _StatChip('MANTEN.', countMaint, statusMeta[PcStatus.maintenance]!.color),
                      const Spacer(),
                      _StatChip('$healthPct%', healthPct, healthColor, labelColor: Colors.grey),
                    ],
                  )
                ],
              ),
            ),

            // FILTROS Y VISTAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterBtn('TODOS', null, computers.length),
                          _FilterBtn('OK', PcStatus.ok, countOk),
                          _FilterBtn('AVERIADOS', PcStatus.broken, countBroken),
                          _FilterBtn('MANTEN.', PcStatus.maintenance, countMaint),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1E2430)), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.grid_view, size: 18),
                          color: isGrid ? Colors.white : Colors.grey,
                          onPressed: () => setState(() => isGrid = true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.view_list, size: 18),
                          color: !isGrid ? Colors.white : Colors.grey,
                          onPressed: () => setState(() => isGrid = false),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // CONTENIDO
            Expanded(
              child: isGrid
                  ? GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: filteredComputers.length,
                itemBuilder: (context, i) => _GridCard(filteredComputers[i], () => _openDetailSheet(filteredComputers[i])),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredComputers.length,
                itemBuilder: (context, i) => _ListRow(filteredComputers[i], () => _openDetailSheet(filteredComputers[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _StatChip(String label, dynamic count, Color color, {Color? labelColor}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: labelColor ?? color, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _FilterBtn(String label, PcStatus? status, int count) {
    bool active = currentFilter == status;
    Color color = status == null ? Colors.white : statusMeta[status]!.color;
    return GestureDetector(
      onTap: () => setState(() => currentFilter = status),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: active ? color : const Color(0xFF1E2430)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: active ? color : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Text('$count', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── COMPONENTES DE VISTA ──

class _GridCard extends StatelessWidget {
  final Computer computer;
  final VoidCallback onTap;
  const _GridCard(this.computer, this.onTap);

  @override
  Widget build(BuildContext context) {
    final meta = statusMeta[computer.status]!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: meta.bg,
          border: Border.all(color: meta.border, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor, color: meta.color, size: 32),
            const SizedBox(height: 6),
            Text(computer.label, style: TextStyle(color: meta.color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final Computer computer;
  final VoidCallback onTap;
  const _ListRow(this.computer, this.onTap);

  @override
  Widget build(BuildContext context) {
    final meta = statusMeta[computer.status]!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: meta.bg,
          border: Border.all(color: meta.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.monitor, color: meta.color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(computer.label, style: TextStyle(color: meta.color, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Fila ${computer.row} · Puesto ${computer.seat} ${computer.note.isNotEmpty ? "· ${computer.note}" : ""}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(meta.label, style: TextStyle(color: meta.color, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(computer.since, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ── BOTTOM SHEET (MODAL DE EDICIÓN) ──

class DetailSheet extends StatefulWidget {
  final Computer computer;
  final Function(PcStatus status, String note) onSave;

  const DetailSheet({super.key, required this.computer, required this.onSave});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late PcStatus pendingStatus;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    pendingStatus = widget.computer.status;
    noteController = TextEditingController(text: widget.computer.note);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = statusMeta[pendingStatus]!;

    // El Padding con viewInsets permite que el teclado no tape el formulario
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1217),
          border: Border.all(color: meta.border),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle (barrita superior)
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)))),

            Row(
              children: [
                Icon(Icons.monitor, color: meta.color, size: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.computer.label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: meta.color)),
                    Text('Fila ${widget.computer.row} · Puesto ${widget.computer.seat}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),

            const Text('CAMBIAR ESTADO', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: PcStatus.values.map((s) {
                final sMeta = statusMeta[s]!;
                final isActive = pendingStatus == s;
                return ChoiceChip(
                  label: Text(sMeta.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? sMeta.color : Colors.grey)),
                  selected: isActive,
                  selectedColor: sMeta.bg,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: isActive ? sMeta.color : Colors.grey[800]!),
                  onSelected: (_) => setState(() => pendingStatus = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('NOTA / DESCRIPCIÓN', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF080A0C),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: meta.color)),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: meta.color,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => widget.onSave(pendingStatus, noteController.text),
              child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            )
          ],
        ),
      ),
    );
  }
}