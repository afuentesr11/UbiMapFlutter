import 'dart:convert';
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
    loadPins();
  }

  void _showPinDialog(LatLng latlng) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Guardar PIN'),
          content: Text('¿Quieres guardar esta localización?\nLatitud: ${latlng.latitude}, Longitud: ${latlng.longitude}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  pins.add({'lat': latlng.latitude, 'lng': latlng.longitude});
                });
                try {
                  await savePins();
                  await saveCoordinatesToCSV(pins); // Guarda las coordenadas en un archivo CSV
                }catch (e) {
                  print('Error guardando el pin: $e');
                }
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCoordinatesToCSV(List<Map<String, double>> coordinates) async {
    List<List<dynamic>> csvData = coordinates.map((coord) => [coord['lat'], coord['lng']]).toList();
    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    await file.writeAsString(csvString);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
              builder: (ctx) => const Icon(Icons.location_on, color: Colors.red),
            );
          }).toList(),
        ),
      ],
    );
  }
}
