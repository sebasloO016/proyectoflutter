import 'package:flutter/material.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';
import 'package:barcode_scanner_app_new/features/maintenance/presentation/add_maintenance_page.dart';

class MaintenancePage extends StatefulWidget {
  final ApiService apiService;

  MaintenancePage({required this.apiService});

  @override
  _MaintenancePageState createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  List<dynamic> _mantenimientos = [];
  Map<int, String> _activos = {}; // Mapa id_activo -> nombre_activo
  Map<int, String> _usuarios = {}; // Mapa id_usuario -> nombre_usuario
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final mantenimientos = await widget.apiService.getMantenimientos();
      final activos = await widget.apiService.getActivos();
      final usuarios = await widget.apiService.getUsuarios();

      final Map<int, String> activosMap = {
        for (var activo in activos) activo['id']: activo['nombre']
      };

      final Map<int, String> usuariosMap = {
        for (var usuario in usuarios) usuario['id']: usuario['nombre']
      };

      setState(() {
        _mantenimientos = mantenimientos;
        _activos = activosMap;
        _usuarios = usuariosMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener datos: $e")),
      );
    }
  }

  Future<void> _deleteMantenimiento(int id) async {
    try {
      await widget.apiService.deleteMantenimiento(id);
      setState(() {
        _mantenimientos
            .removeWhere((mantenimiento) => mantenimiento['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mantenimiento eliminado con éxito")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar mantenimiento: $e")),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar Mantenimiento"),
          content:
              Text("¿Estás seguro de que deseas eliminar este mantenimiento?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMantenimiento(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddMaintenance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMaintenancePage(apiService: widget.apiService),
      ),
    ).then((_) => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Lista de Mantenimientos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mantenimientos.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay mantenimientos registrados",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _mantenimientos.length,
                        itemBuilder: (context, index) {
                          final mantenimiento = _mantenimientos[index];
                          final nombreActivo =
                              _activos[mantenimiento['id_activo']] ??
                                  "Activo desconocido";
                          final nombreUsuario =
                              _usuarios[mantenimiento['creado_por']] ??
                                  "Usuario desconocido";

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 4,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueGrey[50]!, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Activo: $nombreActivo",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Descripción: ${mantenimiento['descripcion']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "Fecha: ${mantenimiento['fecha']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "Costo: \$${mantenimiento['costo']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "Piezas Reemplazadas: ${mantenimiento['piezas_reemplazadas'] ?? 'Ninguna'}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "Creado en: ${mantenimiento['creado_en']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "Creado por: $nombreUsuario",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _confirmDelete(mantenimiento['id']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navigateToAddMaintenance,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.teal,
                elevation: 6,
                shadowColor: Colors.tealAccent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Agregar Mantenimiento",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
