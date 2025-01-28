import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';

class QRScannerAuditPage extends StatefulWidget {
  final ApiService apiService;

  QRScannerAuditPage({required this.apiService});

  @override
  _QRScannerAuditPageState createState() => _QRScannerAuditPageState();
}

class _QRScannerAuditPageState extends State<QRScannerAuditPage> {
  String _scannedCode = "";
  Map<String, dynamic>? _itemData;
  String? _selectedState;
  final TextEditingController _notesController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

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
      setState(() {
        _itemData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _submitAudit() async {
    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor selecciona un estado")),
      );
      return;
    }

    if (_itemData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Primero escanea un código QR válido")),
      );
      return;
    }

    try {
      await widget.apiService.registerAuditoria({
        "id_activo": _itemData!['id'],
        "id_usuario":
            4, // ID del usuario autenticado (ajusta según sea necesario)
        "estado": _selectedState,
        "notas": _notesController.text.trim(),
        "foto": _selectedImage?.path ?? "", // Ruta de la foto seleccionada
        "creado_por": 4, // ID del usuario autenticado
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auditoría registrada con éxito")),
      );

      // Resetea el formulario después de registrar la auditoría
      setState(() {
        _itemData = null;
        _selectedState = null;
        _notesController.clear();
        _selectedImage = null;
        _scannedCode = "";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al registrar auditoría: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Auditoría de Activo",
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
            if (_itemData != null) ...[
              Text(
                "Activo: ${_itemData!['nombre']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Ubicación: ${_itemData!['ubicacion']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedState,
                items: const [
                  DropdownMenuItem(
                      value: "funcionando", child: Text("Funcionando")),
                  DropdownMenuItem(
                      value: "mantenimiento",
                      child: Text("Requiere Reparación")),
                  DropdownMenuItem(
                      value: "fuera_de_servicio",
                      child: Text("Fuera de Servicio")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Estado",
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
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Notas",
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
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _selectedImage != null
                  ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_selectedImage!.path)),
                        ),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text(
                            "Cambiar Foto",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Adjuntar Foto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAudit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Registrar Auditoría",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ] else
              const Text(
                "Escanea un código QR para continuar con la auditoría.",
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
