import 'package:flutter/material.dart';
import 'package:flutterproyect/globals.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

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
            title: Text('Pin ${index + 1}'),
            subtitle: Text('Latitud: ${pin['lat']}, Longitud: ${pin['lng']}'),
          );
        },
      ),
    );
  }
}
