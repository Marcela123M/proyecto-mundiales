import 'package:flutter_test/flutter_test.dart';
import 'package:mundiales_app/models.dart';

void main() {
  test('Mundial.fromJson lee al campeón', () {
    final m = Mundial.fromJson({
      'id': 23,
      'anio': 2026,
      'sede': 'Estados Unidos, México y Canadá',
      'campeon': {'id': 5, 'nombre': 'España', 'continente': 'Europa'},
      'subcampeon': 'Argentina',
      'marcador': '1-0 (prórroga)',
    });
    expect(m.campeon, 'España');
    expect(m.anio, 2026);
  });
}
