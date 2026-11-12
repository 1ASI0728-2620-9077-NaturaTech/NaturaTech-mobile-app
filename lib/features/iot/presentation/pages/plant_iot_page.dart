import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/models/iot_node.dart';
import '../../domain/repositories/iot_repository.dart';
import '../../../../core/ui/toast_helper.dart';
import 'iot_dashboard_page.dart';

/// Página de gestión IoT de una planta:
///  - Si no hay nodo vinculado: muestra aviso + formulario para vincular.
///  - Si hay nodo vinculado: muestra el nodo, un botón para ver la telemetría
///    y un botón para desvincular.
class PlantIotPage extends StatefulWidget {
  final int plantId;
  final int profileId;
  final String plantName;

  const PlantIotPage({
    required this.plantId,
    required this.profileId,
    this.plantName = '',
    super.key,
  });

  @override
  State<PlantIotPage> createState() => _PlantIotPageState();
}

class _PlantIotPageState extends State<PlantIotPage> {
  final IotRepository _repo = GetIt.instance<IotRepository>();
  final TextEditingController _nodeCodeCtrl = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  IotNode? _node;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  @override
  void dispose() {
    _nodeCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNode() async {
    setState(() => _loading = true);
    try {
      final node = await _repo.getNodeForPlant(widget.profileId, widget.plantId);
      if (!mounted) return;
      setState(() {
        _node = node;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ToastHelper.error(context, "No se pudo consultar el dispositivo.");
    }
  }

  Future<void> _link() async {
    final code = _nodeCodeCtrl.text.trim();
    if (code.isEmpty) {
      ToastHelper.error(context, "Escribe el código del dispositivo (nodeCode).");
      return;
    }
    setState(() => _busy = true);
    try {
      await _repo.linkNode(code, widget.plantId, widget.profileId);
      if (!mounted) return;
      ToastHelper.show(context, "Dispositivo '$code' vinculado.");
      _nodeCodeCtrl.clear();
      await _loadNode();
    } catch (e) {
      if (!mounted) return;
      ToastHelper.error(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unlink() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desvincular dispositivo"),
        content: Text(
            "¿Seguro que quieres desconectar el nodo '${_node!.nodeCode}' de esta planta?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Desvincular",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await _repo.unlinkNode(_node!.nodeCode);
      if (!mounted) return;
      ToastHelper.show(context, "Dispositivo desvinculado.");
      await _loadNode();
    } catch (e) {
      if (!mounted) return;
      ToastHelper.error(context, "No se pudo desvincular el dispositivo.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dispositivo IoT")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _node == null ? _buildNoNode() : _buildHasNode(),
            ),
    );
  }

  // -------------------- Sin nodo vinculado --------------------
  Widget _buildNoNode() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.orange[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Esta planta aún no tiene un ESP32 (nodo IoT) vinculado.\n"
                      "Vincula un dispositivo para ver sus sensores y controlar los actuadores.",
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Vincular dispositivo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nodeCodeCtrl,
            decoration: const InputDecoration(
              labelText: "Código del dispositivo (nodeCode)",
              hintText: "ej. esp32-wokwi-001",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.memory),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _busy ? null : _link,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.link),
            label: const Text("Vincular a esta planta"),
          ),
        ],
      ),
    );
  }

  // -------------------- Con nodo vinculado --------------------
  Widget _buildHasNode() {
    final node = _node!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2E7D32),
                child: Icon(Icons.memory, color: Colors.white),
              ),
              title: Text(node.nodeCode,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Estado: ${node.status}"),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IotDashboardPage(
                    plantId: widget.plantId,
                    nodeCode: node.nodeCode,
                    plantName: widget.plantName,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.sensors),
            label: const Text("Ver sensores y actuadores",
                style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _unlink,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.link_off),
            label: const Text("Desvincular dispositivo"),
          ),
        ],
      ),
    );
  }
}
