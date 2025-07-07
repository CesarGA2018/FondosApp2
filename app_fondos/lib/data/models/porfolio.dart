class Portfolio {
  final String id;
  final String nombre;
  final int montoMinimo;
  final String categoria;

  Portfolio({
    required this.id,
    required this.nombre,
    required this.montoMinimo,
    required this.categoria,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      montoMinimo: json['montoMinimo'] as int,
      categoria: json['categoria'] as String,
    );
  }
}
