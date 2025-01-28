//se maneja  la lógica relacionada con la obtención de datos desde la API y la interacción con la base de datos. Aquí tendrás un archivo llamado auth_repository.dart que maneja la lógica de la llamada a la API de login.
import 'package:barcode_scanner_app_new/core/network/api_client.dart';
//import 'package:barcode_scanner_app_new/core/network/api_endpoints.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  // Método para registrar un nuevo usuario
  Future<Map<String, dynamic>> registerUser(
      String nombre, String correo, String contrasena, String rol) async {
    return await apiClient.registerUser(nombre, correo, contrasena, rol);
  }

  // Método para iniciar sesión
  Future<Map<String, dynamic>> loginUser(
      String correo, String contrasena) async {
    return await apiClient.loginUser(correo, contrasena);
  }
}
