import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ubimap/Clases/Pin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Clases/dataBase.dart';

List<Pin> pins = [];
Map<int, Marker> markerMap = {};

Future<void> loadPins() async {
  final prefs = await SharedPreferences.getInstance();
  final String? pinsString = prefs.getString('pins');

  if (pinsString != null) {
    try {
      List<dynamic> pinsJson = jsonDecode(pinsString);
      pins = pinsJson.map((pin) {
        return Pin(
          name: pin['name'],
          latitude: pin['lat'],
          longitude: pin['lng'],
        );
      }).toList();

    } catch (e) {
      print('Error decoding pins: $e');
    }
  }
}

Future<void> savePinToSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final String pinsString = jsonEncode(pins.map((pin) => pin.toMap()).toList());
  await prefs.setString('pins', pinsString);
}

Future<void> loadPinsFromDB() async {
  final List<Pin> dbPins = await DBHelper.getPins();
  pins = dbPins;
}

Future<void> deletePinFromDB(int id) async {
  await DBHelper.deletePin(id);
  markerMap.remove(id);
  await loadPinsFromDB(); // Recargar los pines después de la eliminación
}

Future<void> deletePinFromEverywhere(Pin pin) async {
  try {
    await deletePinFromDB(pin.id);
    print("Pin borrado de DB");
    await deletePinFromSharedPreferences(pin.name);
    print("Pin borrado de SharedPreferences");
    await deletePinFromCSV(pin.name);
    print("Pin borrado de CSV");
  }catch (e) {
    print('No se pudo borrar el pin: $e');
  }
}

Future<void> deletePinFromSharedPreferences(String pinName) async {
  final prefs = await SharedPreferences.getInstance();

  // Recupera la lista actual de pines almacenada en SharedPreferences
  final String? pinsString = prefs.getString('pins');

  if (pinsString != null) {
    // Convierte la cadena de pines de SharedPreferences a una lista
    List<dynamic> pinsJson = jsonDecode(pinsString);

    // Busca y elimina el pin con el nombre especificado
    pinsJson.removeWhere((pin) => pin['name'] == pinName);

    // Convierte la lista actualizada de pines de nuevo a un formato de cadena
    final String updatedPinsString = jsonEncode(pinsJson);

    // Actualiza la cadena en SharedPreferences
    await prefs.setString('pins', updatedPinsString);
  }
}

Future<void> deletePinFromCSV(String pinName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/coordinates.csv');

  if (await file.exists()) {
    // Lee el contenido actual del archivo CSV
    String csvString = await file.readAsString();

    // Convierte el contenido del archivo en una lista de listas de datos
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

    // Busca y elimina el pin con el nombre especificado de la lista de datos
    csvData.removeWhere((row) => row[0] == pinName);

    // Convierte la lista actualizada de datos nuevamente a una cadena CSV
    String updatedCsvString = const ListToCsvConverter().convert(csvData);

    // Escribe la cadena actualizada de nuevo en el archivo CSV
    await file.writeAsString(updatedCsvString);
  }
}

Future<void> clearPinsFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('pins');
}

Future<void> clearPinsFromCSV() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/coordinates.csv');

  if (await file.exists()) {
    await file.writeAsString('');  // Escribir una cadena vacía en el archivo
  }
}

