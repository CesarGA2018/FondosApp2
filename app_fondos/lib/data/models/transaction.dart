class Transaction {
  final String id;
  final String fondo;
  final String tipo;
  final String fecha;
  final int monto;
  final String userId;

  Transaction({
    required this.id,
    required this.fondo,
    required this.tipo,
    required this.fecha,
    required this.monto,
    required this.userId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      fondo: json['fondo'],
      tipo: json['tipo'],
      fecha: json['fecha'],
      monto: json['monto'],
      userId: json['userId'],
    );
  }
}
