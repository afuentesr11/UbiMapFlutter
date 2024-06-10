import 'package:flutter/material.dart';
import 'package:flutterproyect/globals.dart';
import 'package:intl/intl.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  String formatNumber(double number) {
    final NumberFormat formatter = NumberFormat("#.###");
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinates'),
      ),
      body: ListView.builder(
        itemCount: pins.length,
        itemBuilder: (context, index) {
          final pin = pins[index];
          return ListTile(
            title: Text('${pin['name']}'),
            subtitle: Text('Latitud: ${formatNumber(pin['lat'])}, Longitud: ${formatNumber(pin['lng'])}'),
          );
        },
      ),
    );
  }
}
