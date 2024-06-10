import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> pins = [];

Future<void> loadPins() async {
  final prefs = await SharedPreferences.getInstance();
  final String? pinsString = prefs.getString('pins');

  if (pinsString != null) {
    try {
      List<dynamic> pinsJson = jsonDecode(pinsString);
      pins = pinsJson.map((pin) => {
        'name': pin['name'],
        'lat': pin['lat'],
        'lng': pin['lng'],
      }).toList();
    } catch (e) {
      print('Error decoding pins: $e');
    }
  }
}


Future<void> savePins() async {
  final prefs = await SharedPreferences.getInstance();
  final String pinsString = jsonEncode(pins);
  await prefs.setString('pins', pinsString);
}
