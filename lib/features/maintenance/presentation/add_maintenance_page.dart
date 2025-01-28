import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';

class AddMaintenancePage extends StatefulWidget {
  final ApiService apiService;

  AddMaintenancePage({required this.apiService});

  @override
  _AddMaintenancePageState createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  String? _tipo;
  Map<String, dynamic>? _activo;
  int? _idUsuario;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _piezasReemplazadasController =
      TextEditingController();
  DateTime? _selectedDate;
  List<dynamic> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    try {
      final usuarios = await widget.apiService.getUsuarios();
      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener usuarios: $e")),
      );
    }
  }

  Future<void> _scanQRCode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        final qrCode = result.rawContent;
        final activo = await widget.apiService.getActivoByQR(qrCode);

        setState(() {
          _activo = activo;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se escaneó ningún código")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al escanear QR: $e")),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _activo != null &&
        _idUsuario != null) {
      try {
        final String formattedDate =
            _selectedDate!.toIso8601String().split('T')[0];

        await widget.apiService.addMantenimiento({
          "id_activo": _activo?['id'],
          "tipo": _tipo,
          "descripcion": _descripcionController.text.trim(),
          "fecha": formattedDate,
          "costo": double.parse(_costoController.text.trim()),
          "piezas_reemplazadas": _piezasReemplazadasController.text.trim(),
          "creado_por": _idUsuario,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mantenimiento registrado con éxito")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar mantenimiento: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor completa todos los campos")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Agregar Mantenimiento",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: _scanQRCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.qr_code_scanner, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Escanear Activo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (_activo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Activo: ${_activo?['nombre']} (ID: ${_activo?['id']})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              DropdownButtonFormField<int>(
                value: _idUsuario,
                items: _usuarios.map((usuario) {
                  return DropdownMenuItem<int>(
                    value: usuario['id'],
                    child: Text("${usuario['nombre']}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _idUsuario = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Selecciona un Usuario",
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
                validator: (value) =>
                    value == null ? "Selecciona un usuario" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: [
                  DropdownMenuItem(
                      value: "preventivo", child: Text("Preventivo")),
                  DropdownMenuItem(
                      value: "correctivo", child: Text("Correctivo")),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Tipo de Mantenimiento",
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
                validator: (value) => value == null
                    ? "Selecciona el tipo de mantenimiento"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _descripcionController,
                label: "Descripción",
                validator: (value) =>
                    value!.isEmpty ? "Ingresa una descripción" : null,
              ),
              _buildInputField(
                controller: _costoController,
                label: "Costo",
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? "Ingresa el costo del mantenimiento"
                    : null,
              ),
              _buildInputField(
                controller: _piezasReemplazadasController,
                label: "Piezas Reemplazadas (Opcional)",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Seleccionar Fecha"
                      : "Fecha: ${_selectedDate?.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Registrar Mantenimiento",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
