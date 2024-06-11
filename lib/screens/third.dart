import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproyect/Clases/Pin.dart';
import 'package:flutterproyect/Clases/dataBase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';

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
    loadAllPins();
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

  Future<void> deletePinFromEverywhere(Pin pin) async {
    await DBHelper.deletePin(pin.id);
    await deletePinFromSharedPreferences(pin);
    await deletePinFromCSV(pin);
    loadAllPins();
  }

  Future<void> deletePinFromSharedPreferences(Pin pin) async {
    final prefs = await SharedPreferences.getInstance();
    final String? pinsString = prefs.getString('pins');
    if (pinsString != null) {
      List<dynamic> pinsJson = jsonDecode(pinsString);
      pinsJson.removeWhere((p) => p['name'] == pin.name && p['latitude'] == pin.latitude && p['longitude'] == pin.longitude);
      await prefs.setString('pins', jsonEncode(pinsJson));
    }
  }

  Future<void> deletePinFromCSV(Pin pin) async {
    List<Pin> csvPins = await loadPinsFromCSV();
    csvPins.removeWhere((p) => p.name == pin.name && p.latitude == pin.latitude && p.longitude == pin.longitude);
    await saveCoordinatesToCSV(csvPins);
  }

  Future<void> saveCoordinatesToCSV(List<Pin> coordinates) async {
    List<List<dynamic>> csvData = coordinates.map((coord) => [coord.name, coord.latitude, coord.longitude]).toList();
    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coordinates.csv');
    await file.writeAsString(csvString);
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
