import 'dart:convert';
import 'package:app_fondos/data/models/porfolio.dart';
import 'package:http/http.dart' as http;// importa el modelo de arriba

Future<List<Portfolio>> fetchPortfolios() async {
  final response = await http.get(Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/portfolios'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List portfoliosJson = data['portfolios'];

    return portfoliosJson.map((json) => Portfolio.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los fondos');
  }
}

Future<List<Map<String, dynamic>>> fetchSubscriptions(String email) async {
  final url = Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/subscriptions/user/$email');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List subs = data['subscriptions'];
    return subs.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Error al obtener suscripciones');
  }
}