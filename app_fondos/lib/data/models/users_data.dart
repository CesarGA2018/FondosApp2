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
