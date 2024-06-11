class Pin {
  static int _currentId = 0;  // Variable estática para mantener el último ID usado

  int id;
  String name;
  double latitude;
  double longitude;

  // Constructor que genera automáticamente un ID incremental
  Pin({required this.name, required this.latitude, required this.longitude})
      : id = ++_currentId;

  // Método para convertir el objeto Pin a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Método estático para crear un objeto Pin desde un mapa
  static Pin fromMap(Map<String, dynamic> map) {
    return Pin(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    )..id = map['id'];  // Asigna el ID desde el mapa
  }

}
