import 'package:app_fondos/data/api/suscriptions_api.dart';
import 'package:app_fondos/data/provider/auth_provider.dart';
import 'package:app_fondos/widgets/bottom_portfolios.dart';
import 'package:app_fondos/widgets/list_founds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Founds extends StatefulWidget {
  const Founds({super.key});

  @override
  State<Founds> createState() => _FoundsState();
}

class _FoundsState extends State<Founds> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().userInfo;
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          color: Colors.blueGrey,
          child: Center(child: Text('Tu saldo es: ${user.saldo}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
        ),
        Expanded(child: listfounds()),
        _submitButton(context),
        SizedBox(
          height: 15,
        )
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    final user = context.watch<AuthState>().userInfo;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final selected = await showPortfolioBottomSheet(context);
          if (selected != null) {
             try {
              // Supongamos que ya tienes el `email` del usuario y un `Portfolio` seleccionado
              final result = await subscribeToFund(
                email: user.email,
                fundId: selected.id,
              );

              // Puedes mostrar mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );

              // También puedes mostrar el nuevo saldo:
              context.read<AuthState>().actualizarSaldo(result['nuevoSaldo'] + 0.0);
            } catch (e) {
              // Mostrar error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
            // Aquí puedes hacer lo que necesites con el fondo seleccionado
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color.fromARGB(255, 6, 6, 6),Color.fromARGB(255, 0, 103, 110)])),
          child: Text(
            'Nuevo',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

