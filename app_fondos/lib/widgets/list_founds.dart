import 'package:app_fondos/data/api/portfolio_api.dart';
import 'package:app_fondos/data/api/suscriptions_api.dart';
import 'package:app_fondos/data/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class listfounds extends StatefulWidget {
  const listfounds({super.key});

  @override
  State<listfounds> createState() => _listfoundsState();
}

class _listfoundsState extends State<listfounds> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSubscriptions(context.watch<AuthState>().userInfo.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No tienes suscripciones.');
        }

        final subs = snapshot.data!;
        return ListView.builder(
          itemCount: subs.length,
          itemBuilder: (context, index) {
            final fund = subs[index];
            return ListTile(
              title: Text(fund['nombre']),
              subtitle: Text('Monto mínimo: \$${fund['montoMinimo']}'),
              trailing: Text(fund['categoria']),
              onTap: () async {
                final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar cancelación'),
                  content: Text('¿Deseas cancelar la suscripción al fondo ${fund['nombre']}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
                  ],
                ),
              );

              if (confirm != true) return;

              try {
                final result = await unsubscribeFromFund(
                  email: context.read<AuthState>().userInfo.email,
                  fundId: fund['id'],
                );

                // ✅ Actualizar el saldo global
                context.read<AuthState>().actualizarSaldo(result['nuevoSaldo'] + 0.0);

                // ✅ Mostrar mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
              },
            );
          },
        );
      },
    );
  }
}