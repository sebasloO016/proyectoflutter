import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';

class QRScannerInfoPage extends StatefulWidget {
  final ApiService apiService;

  QRScannerInfoPage({required this.apiService});

  @override
  _QRScannerInfoPageState createState() => _QRScannerInfoPageState();
}

class _QRScannerInfoPageState extends State<QRScannerInfoPage> {
  String _scannedCode = "";
  Map<String, dynamic>? _itemData;
  List<dynamic> _auditorias = [];
  final TextEditingController _manualCodeController = TextEditingController();

  Future<void> _scanQR() async {
    try {
      final result = await BarcodeScanner.scan();
      setState(() {
        _scannedCode = result.rawContent;
      });

      if (_scannedCode.isNotEmpty) {
        await _fetchItemData(_scannedCode);
      }
    } catch (e) {
      print("Error al escanear: $e");
    }
  }

  Future<void> _fetchItemData(String code) async {
    try {
      final data = await widget.apiService.getActivoByQR(code);
      final allAuditorias = await widget.apiService.getAllAuditorias();

      // Filtra auditorías relacionadas al activo actual
      final relatedAuditorias = allAuditorias
          .where((auditoria) => auditoria['id_activo'] == data['id'])
          .toList();

      setState(() {
        _itemData = data;
        _auditorias = relatedAuditorias;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _submitManualCode() {
    final manualCode = _manualCodeController.text.trim();
    if (manualCode.isNotEmpty) {
      _fetchItemData(manualCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa un código válido")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Información del Activo",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _scanQR,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text(
                "Escanear Código QR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _manualCodeController,
              decoration: InputDecoration(
                labelText: "Ingresar Código Manualmente",
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitManualCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Buscar por Código",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_itemData != null) ...[
              Text(
                "Nombre: ${_itemData!['nombre']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Tipo: ${_itemData!['tipo']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "Ubicación: ${_itemData!['ubicacion']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "Estado Actual: ${_itemData!['estado']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              if (_auditorias.isNotEmpty) ...[
                const Text(
                  "Última Auditoría",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Estado: ${_auditorias[0]['estado']}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Notas: ${_auditorias[0]['notas']}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Fecha: ${_auditorias[0]['fecha']}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const Divider(),
                const Text(
                  "Historial de Auditorías",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                ..._auditorias.map((auditoria) => ListTile(
                      title: Text(
                        "Estado: ${auditoria['estado']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Notas: ${auditoria['notas']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        "Fecha: ${auditoria['fecha']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    )),
              ] else
                const Text(
                  "No hay auditorías recientes para este activo.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
            ] else
              const Text(
                "Escanea o ingresa un código para mostrar los datos.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
