import 'dart:convert';
import 'package:app_fondos/data/models/users_data.dart';
import 'package:http/http.dart' as http;

Future<UserApp?> fetchUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https://769a3aqghl.execute-api.us-east-1.amazonaws.com/dev/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userJson = data['user'];
      if (userJson != null) {
        return UserApp.fromJson(userJson);
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}
