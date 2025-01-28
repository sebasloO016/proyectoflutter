import 'package:flutter/material.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';

class AddItemPage extends StatefulWidget {
  final ApiService apiService;

  AddItemPage({required this.apiService});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoQRController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _numeroSerieController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addActivo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.addActivo({
        "codigo_qr": _codigoQRController.text.trim(),
        "nombre": _nombreController.text.trim(),
        "tipo": _tipoController.text.trim(),
        "ubicacion": _ubicacionController.text.trim(),
        "numero_serie": _numeroSerieController.text.trim(),
        "costo": double.parse(_costoController.text.trim()),
        "proveedor": _proveedorController.text.trim(),
        "estado": "funcionando",
        "creado_por": 4,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activo agregado exitosamente: ${response['nombre']}'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar activo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Agregar Nuevo Activo",
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
              _buildInputField(
                controller: _codigoQRController,
                label: "Código QR",
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              _buildInputField(
                controller: _nombreController,
                label: "Nombre del Activo",
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              _buildInputField(
                controller: _tipoController,
                label: "Tipo",
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              _buildInputField(
                controller: _ubicacionController,
                label: "Ubicación",
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              _buildInputField(
                controller: _numeroSerieController,
                label: "Número de Serie",
              ),
              _buildInputField(
                controller: _costoController,
                label: "Costo",
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              _buildInputField(
                controller: _proveedorController,
                label: "Proveedor",
                validator: (value) =>
                    value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _addActivo,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Agregar Activo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
