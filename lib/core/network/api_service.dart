import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Obtener usuarios
  Future<List<dynamic>> getUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/api/usuarios'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  // Obtener activos
  Future<List<dynamic>> getActivos() async {
    final response = await http.get(Uri.parse('$baseUrl/api/activos'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener activos');
    }
  }

  // Obtener auditorías
  Future<List<dynamic>> getAuditorias() async {
    final response = await http.get(Uri.parse('$baseUrl/api/auditorias'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener auditorías');
    }
  }

  // Agregar activo
  Future<Map<String, dynamic>> addActivo(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/activos');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al agregar activo: ${response.body}');
    }
  }

  //Obtener activo por QR
  Future<Map<String, dynamic>> getActivoByQR(String qrCode) async {
    final url = Uri.parse('$baseUrl/api/activos?codigo_qr=$qrCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      // Filtra el activo con el código QR exacto
      final filtered =
          responseData.where((item) => item['codigo_qr'] == qrCode).toList();

      if (filtered.isNotEmpty) {
        return filtered.first; // Devuelve el primer elemento encontrado
      } else {
        throw Exception('No se encontró ningún activo con este código QR');
      }
    } else {
      throw Exception('Error al obtener el activo: ${response.body}');
    }
  }

  //auditoria por qr
  Future<void> registerAuditoria(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/auditorias');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al registrar auditoría: ${response.body}');
    }
  }

//metodo para obtener todas las auditorias
  Future<List<dynamic>> getAllAuditorias() async {
    final url = Uri.parse('$baseUrl/api/auditorias');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); // Devuelve todas las auditorías
    } else {
      throw Exception('Error al obtener las auditorías');
    }
  }

  //METODO PARA OBTENER LOS MANTENIMIENTOS
  Future<List<dynamic>> getMantenimientos() async {
    final url = Uri.parse('$baseUrl/api/mantenimientos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los mantenimientos: ${response.body}');
    }
  }

  //METODO PARA AGREGAR MANTENIMIENTO
  Future<void> addMantenimiento(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/mantenimientos');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar el mantenimiento: ${response.body}');
    }
  }

  //eliminar metodo mantenimiento
  Future<void> deleteMantenimiento(int id) async {
    final url = Uri.parse('$baseUrl/api/mantenimientos/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar mantenimiento: ${response.body}');
    }
  }
}
