import 'dart:convert';
import 'package:app_fondos/data/models/transaction.dart';
import 'package:http/http.dart' as http;

Future<List<Transaction>> fetchTransactions(String email) async {
  final url = Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/transactions/user/$email');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Transaction.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener transacciones');
  }
}
