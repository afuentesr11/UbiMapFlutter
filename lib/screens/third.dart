import 'package:flutter/material.dart';
import 'package:flutterproyect/globals.dart'; // Asegúrate de que este archivo contiene la lista de pines global
import 'package:flutterproyect/Clases/Pin.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  List<Pin> pins = [];

  @override
  void initState() {
    super.initState();
    loadPinsFromDB();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pines'),
      ),
      body: ListView.builder(
        itemCount: pins.length,
        itemBuilder: (context, index) {
          final pin = pins[index];
          return ListTile(
            title: Text(pin.name),
            subtitle: Text('Lat: ${pin.latitude}, Lng: ${pin.longitude}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await deletePinFromEverywhere(pin);
              },
            ),
          );
        },
      ),
    );
  }
}
