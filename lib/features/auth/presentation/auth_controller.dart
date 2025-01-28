import 'package:flutter/material.dart';
import 'package:barcode_scanner_app_new/features/auth/data/auth_repository.dart';

class AuthController with ChangeNotifier {
  final AuthRepository authRepository;

  // Campo privado para almacenar datos del usuario autenticado
  Map<String, dynamic>? _currentUser;

  // Getter para acceder a los datos del usuario
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthController({required this.authRepository});

  // Método para registrar un usuario
  Future<void> registerUser(BuildContext context, String nombre, String correo,
      String contrasena, String rol) async {
    try {
      final response =
          await authRepository.registerUser(nombre, correo, contrasena, rol);

      if (response.containsKey('id')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      } else {
        showError(context, 'Error al registrar usuario');
      }
    } catch (e) {
      showError(context, 'Error al registrar usuario: $e');
      print("Error al registrar usuario:");
    }
  }

  // Método para mostrar errores de forma más amigable
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Método para hacer login
  Future<void> loginUser(
      BuildContext context, String correo, String contrasena) async {
    try {
      final response = await authRepository.loginUser(correo, contrasena);

      if (response.containsKey('token')) {
        // Guarda los datos del usuario autenticado
        _currentUser = response;

        // Notifica cambios a los listeners
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso')),
        );

        // Redirige al Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } catch (e) {
      showError(context, 'Error al iniciar sesión: $e');
    }
  }
}
