String _stringFromJson(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value.trim();
  if (value is Map) {
    final nombre = value['nombre'] ?? value['name'] ?? value['pais'] ?? value['equipo'];
    return _stringFromJson(nombre, fallback: fallback);
  }
  return value.toString().trim();
}

int _intFromJson(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
    final asDouble = double.tryParse(value.trim());
    if (asDouble != null) return asDouble.toInt();
  }
  return fallback;
}

class TitulosSeleccion {
  const TitulosSeleccion({required this.nombre, required this.titulos});

  final String nombre;
  final int titulos;

  factory TitulosSeleccion.fromJson(Map<String, dynamic> j) => TitulosSeleccion(
        nombre: _stringFromJson(j['nombre']),
        titulos: _intFromJson(j['titulos']),
      );
}

class Mundial {
  const Mundial({
    required this.id,
    required this.anio,
    required this.sede,
    required this.campeon,
    required this.subcampeon,
    required this.marcador,
  });

  final int id;
  final int anio;
  final String sede;
  final String campeon;
  final String subcampeon;
  final String marcador;

  factory Mundial.fromJson(Map<String, dynamic> j) => Mundial(
        id: _intFromJson(j['id']),
        anio: _intFromJson(j['anio']),
        sede: _stringFromJson(j['sede']),
        campeon: _stringFromJson(j['campeon']),
        subcampeon: _stringFromJson(j['subcampeon']),
        marcador: _stringFromJson(j['marcador'], fallback: '-'),
      );
}
