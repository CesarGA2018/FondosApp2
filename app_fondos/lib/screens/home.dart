import 'package:app_fondos/data/provider/auth_provider.dart';
import 'package:app_fondos/screens/login.dart';
import 'package:app_fondos/widgets/founds.dart';
import 'package:app_fondos/widgets/movement_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _configureByRole(String rol) {
    if (rol == 'consultor') {
      _screens = const [
        Center(child: Founds()),
        Center(child: Text('Historico')),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Fondos'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historico'),
      ];
    } else if (rol == 'cliente') {
      _screens = const [
        Center(child: Founds()),
        Center(child: movement_list()),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Fondos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.timelapse),
          label: 'Movimientos',
        ),
      ];
    } else {
      //Admin
      _screens = const [
        Center(child: Text('Historico')),
        Center(child: Text('Gestión de fondos')),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historico'),
        BottomNavigationBarItem(
          icon: Icon(Icons.balance_sharp),
          label: 'Gestión de fondos',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().userInfo;
    _configureByRole(user.rol);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${user.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthState>().logout();

              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (
                        BuildContext context,
                        Animation animation,
                        Animation secondaryAnimation,
                      ) {
                        return LoginPage();
                      },
                  transitionsBuilder:
                      (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                ),
                (Route route) => false,
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
