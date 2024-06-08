import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, double>> pins = [];

Future<void> savePins() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String encodedPins = pins.map((pin) => '${pin['lat']},${pin['lng']}').join(';');
  await prefs.setString('pins', encodedPins);
}

Future<void> loadPins() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? pinsString = prefs.getString('pins');
  if (pinsString != null) {
    pins = pinsString.split(';').map((s) {
      List<String> coords = s.split(',');
      return {'lat': double.parse(coords[0]), 'lng': double.parse(coords[1])};
    }).toList();
  }
}
