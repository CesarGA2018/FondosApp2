import 'package:app_fondos/data/api/portfolio_api.dart';
import 'package:app_fondos/data/models/porfolio.dart';
import 'package:flutter/material.dart';

Future<Portfolio?> showPortfolioBottomSheet(BuildContext context) {
  return showModalBottomSheet<Portfolio>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return FutureBuilder<List<Portfolio>>(
        future: fetchPortfolios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No se encontraron fondos.'),
            );
          }

          final portfolios = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Fondos Disponibles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: portfolios.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final p = portfolios[index];
                    return ListTile(
                      title: Text(p.nombre),
                      subtitle: Text('Mínimo: \$${p.montoMinimo}'),
                      onTap: () {
                        Navigator.pop(context, p); // ✅ devuelve el fondo seleccionado
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
