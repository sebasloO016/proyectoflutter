import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:barcode_scanner_app_new/core/constants/app_strings.dart'; // CONSTANTES PARA DECIR QUE SUCEDE EN CADA PARTE POR EJEMPLO, LOGIN EXITOSO!

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  // Método para enviar una solicitud POST al registro de usuario
  Future<Map<String, dynamic>> registerUser(
      String nombre, String correo, String contrasena, String rol) async {
    final url = Uri.parse('$baseUrl/api/usuarios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol,
      }),
    );
    return _processResponse(response);
  }

  // Método para enviar una solicitud POST al login de usuario
  Future<Map<String, dynamic>> loginUser(
      String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/api/usuarios/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );
    return _processResponse(response);
  }

  // Método para procesar la respuesta del servidor
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body); // Respuesta exitosa
    } else {
      throw Exception(
          'Error en la solicitud: ${response.body}'); // Error en la solicitud
    }
  }
}
