import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterproyect/Clases/Pin.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterproyect/globals.dart';
import 'package:flutterproyect/Clases/dataBase.dart';

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
        print('Pins loaded:');
        for (var pin in pins) {
          print('ID: ${pin.id}, Name: ${pin.name}, Latitude: ${pin.latitude}, Longitude: ${pin.longitude}');
        }
        _updateMarkers();
      });
    });
  }

  void _updateMarkers() {
    markerMap.clear();
    for (var pin in pins) {
      markerMap[pin.id] = Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(pin.latitude, pin.longitude),
        builder: (ctx) => Column(
          children: [
            Text(
              pin.name,
              style: const TextStyle(color: Colors.black),
            ),
            const Icon(Icons.location_on, color: Colors.red),
          ],
        ),
      );
    }
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
                  pins.add(
                  Pin(name: nameController.text, latitude: latlng.latitude, longitude: latlng.longitude)
                  );
                });
                try {
                  await savePins();
                  await saveCoordinatesToCSV(pins);
                  await savePinToDB(nameController.text, latlng.latitude, latlng.longitude);
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

  Future<void> saveCoordinatesToCSV(List<Pin> coordinates) async {
    List<List<dynamic>> csvData = coordinates.map((coord) => [coord.name, coord.latitude, coord.longitude]).toList();
    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    await file.writeAsString(csvString);
  }

  Future<void> savePinToDB(String name, double lat, double lng) async {
    Pin pin = new Pin(name: name, latitude: lat, longitude: lng);
    await DBHelper.insertPin(pin);
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
            markers: markerMap.values.toList(), // Usar los marcadores del mapa
          ),
        ],
      ),
    );
  }
}
