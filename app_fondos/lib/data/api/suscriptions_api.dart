import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> subscribeToFund({
  required String email,
  required String fundId,
}) async {
  final url = Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/subscriptions');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'fundId': fundId}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Error al suscribirse al fondo');
  }
}

Future<Map<String, dynamic>> unsubscribeFromFund({
  required String email,
  required String fundId,
}) async {
  final url = Uri.parse(
    'https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/subscriptions/$fundId?email=$email',
  );

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Error al cancelar la suscripción');
  }
}