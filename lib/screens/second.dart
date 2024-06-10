import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterproyect/globals.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
    loadPins().then((_) {
      setState(() {
        print('Pins loaded: $pins');
      });
    });
  }

  void _showPinDialog(LatLng latlng) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Guardar Pin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Quieres guardar esta localización?\nLatitud: ${latlng.latitude}, Longitud: ${latlng.longitude}'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  pins.add({
                    'name': nameController.text,
                    'lat': latlng.latitude,
                    'lng': latlng.longitude,
                  });
                });
                try {
                  await savePins();
                  await saveCoordinatesToCSV(pins);
                } catch (e) {
                  print('Error guardando el pin: $e');
                }
                Navigator.of(context).pop(); // Cierra el diálogo después de guardar
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCoordinatesToCSV(List<Map<String, dynamic>> coordinates) async {
    List<List<dynamic>> csvData = coordinates.map((coord) => [coord['name'], coord['lat'], coord['lng']]).toList();
    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    await file.writeAsString(csvString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: FlutterMap(
        options: MapOptions(
          onTap: (tapPosition, latlng) {
            _showPinDialog(latlng);
          },
          center: LatLng(40.4168, -3.7038), // Centro en Madrid
          zoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: pins.map((pin) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(pin['lat']!, pin['lng']!),
                builder: (ctx) => Column(
                  children: [
                    Text(
                      pin['name']!,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const Icon(Icons.location_on, color: Colors.red),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
