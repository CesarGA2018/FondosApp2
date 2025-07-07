import 'package:app_fondos/data/api/transaction_api.dart';
import 'package:app_fondos/data/models/transaction.dart';
import 'package:app_fondos/data/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class movement_list extends StatelessWidget {
  const movement_list({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
        future: fetchTransactions(context.watch<AuthState>().userInfo.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay transacciones.'));
          }

          final transactions = snapshot.data!;
          return ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                leading: Icon(
                  tx.tipo == 'apertura' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: tx.tipo == 'apertura' ? Colors.green : Colors.red,
                ),
                title: Text(tx.fondo),
                subtitle: Text('Fecha: ${tx.fecha.substring(0, 10)}'),
                trailing: Text('\$${tx.monto}', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      );
  }
}