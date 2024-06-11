import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ubimap/globals.dart';
import 'package:ubimap/Clases/dataBase.dart';
import 'package:ubimap/Clases/Pin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
    loadAllPins().then((_) {
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
    String selectedStorage = 'Database'; // Default selection

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
              DropdownButton<String>(
                value: selectedStorage,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStorage = newValue!;
                  });
                },
                items: <String>['Database', 'SharedPreferences', 'CSV']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
                Pin newPin = Pin(name: nameController.text, latitude: latlng.latitude, longitude: latlng.longitude);
                setState(() {
                  pins.add(newPin);
                });
                try {
                  switch (selectedStorage) {
                    case 'Database':
                      await savePinToDB(newPin);
                      break;
                    case 'SharedPreferences':
                      await savePinToSharedPreferences(newPin);
                      break;
                    case 'CSV':
                      await savePinToCSV(newPin);
                      break;
                  }
                  await loadAllPins();
                  _updateMarkers();
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

  Future<void> savePinToDB(Pin pin) async {
    await DBHelper.insertPin(pin);
  }

  Future<void> savePinToSharedPreferences(Pin pin) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Pin> sharedPrefsPins = await loadPinsFromSharedPreferences();
    sharedPrefsPins.add(pin);
    final String pinsString = jsonEncode(sharedPrefsPins.map((pin) => pin.toMap()).toList());
    await prefs.setString('pins', pinsString);
  }

  Future<void> savePinToCSV(Pin pin) async {
    final List<Pin> csvPins = await loadPinsFromCSV();
    csvPins.add(pin);
    await saveCoordinatesToCSV(csvPins);
  }

  Future<void> saveCoordinatesToCSV(List<Pin> coordinates) async {
    List<List<dynamic>> csvData = coordinates.map((coord) => [coord.name, coord.latitude, coord.longitude]).toList();
    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    await file.writeAsString(csvString);
  }

  Future<void> loadAllPins() async {
    List<Pin> dbPins = await loadPinsFromDB();
    List<Pin> sharedPreferencesPins = await loadPinsFromSharedPreferences();
    List<Pin> csvPins = await loadPinsFromCSV();

    setState(() {
      pins = [...dbPins, ...sharedPreferencesPins, ...csvPins];
    });
  }

  Future<List<Pin>> loadPinsFromDB() async {
    return await DBHelper.getPins();
  }

  Future<List<Pin>> loadPinsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pinsString = prefs.getString('pins');
    if (pinsString != null) {
      List<dynamic> pinsJson = jsonDecode(pinsString);
      return pinsJson.map((pin) => Pin.fromMap(pin)).toList();
    }
    return [];
  }

  Future<List<Pin>> loadPinsFromCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    if (!file.existsSync()) {
      return [];
    }

    String csvString = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
    return csvData.map((coord) => Pin(
      name: coord[0] as String,
      latitude: coord[1] as double,
      longitude: coord[2] as double,
    )).toList();
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
