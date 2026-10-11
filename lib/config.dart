import 'package:flutter/foundation.dart';

/// Dirección de la API.
/// Para cambiarla sin tocar código:
///   flutter run --dart-define=API_URL=http://192.168.1.50:8000
String get baseUrl {
  const desdeEntorno = String.fromEnvironment('API_URL');
  if (desdeEntorno.isNotEmpty) return desdeEntorno;
  // El emulador de Android ve el PC como 10.0.2.2
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://127.0.0.1:8000';
}
