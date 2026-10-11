import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> _get(String ruta) async {
    final res = await _client
        .get(Uri.parse('$baseUrl$ruta'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('La API respondió ${res.statusCode} en $ruta');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<List<TitulosSeleccion>> titulos() async {
    final datos = await _get('/graficas/titulos-por-seleccion/datos') as List<dynamic>;
    return datos
        .map((e) => TitulosSeleccion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Mundial>> mundiales() async {
    final datos = await _get('/mundiales/') as List<dynamic>;
    return datos.map((e) => Mundial.fromJson(e as Map<String, dynamic>)).toList();
  }
}
