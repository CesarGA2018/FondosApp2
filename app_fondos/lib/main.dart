import 'package:app_fondos/data/provider/auth_provider.dart';
import 'package:app_fondos/screens/home.dart';
import 'package:app_fondos/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
     return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: MaterialApp(
        title: 'App Fondos',
        theme: ThemeData(primarySwatch: Colors.indigo),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthState>(
          builder: (context, authState, _) {
            if (!authState.initialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return authState.isAuthorized
                ? const Home()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
