import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserApp {
  final String nombre;
  final String email;
  final String password;
  final String rol;
  final double saldo;

  const UserApp({
    this.nombre = '',
    this.email = '',
    this.password = '',
    this.rol = '',
    this.saldo = 0.0,
  });

  factory UserApp.fromJson(Map<String, dynamic> json) {
    return UserApp(
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rol: json['rol'] ?? '',
      saldo: (json['saldo'] ?? 0).toDouble(),
    );
  }
}

class AuthState extends ChangeNotifier {
  UserApp _user = const UserApp();
  UserApp get userInfo => _user;

  bool _initialized = false;
  bool get initialized => _initialized;

  AuthState() {
    _init();
  }

  Future<void> _init() async {
    await tryLogin();
    _initialized = true;
    notifyListeners();
  }

  bool get isAuthorized => _user.email.isNotEmpty && _user.rol.isNotEmpty;

  void actualizarSaldo(double nuevoSaldo) {
    _user = UserApp(
      nombre: _user.nombre,
      email: _user.email,
      password: _user.password,
      rol: _user.rol,
      saldo: nuevoSaldo,
    );
    notifyListeners();
  }

  Future<bool> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email == null || password == null) return false;

    final user = await _fetchUser(email, password);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<UserApp?> tryLoginWithCredentials(String email, String password) async {
    final user = await _fetchUser(email, password);
    if (user != null) {
      _user = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      notifyListeners();
      return user;
    }
    return null;
  }

  void logout() async {
    _user = const UserApp();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<UserApp?> _fetchUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userJson = data['user'];
        return UserApp.fromJson(userJson);
      }

      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
}
