import 'package:flutter/material.dart';

import 'home_page.dart';
import 'widgets.dart';

void main() => runApp(const MundialesApp());

class MundialesApp extends StatelessWidget {
  const MundialesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundiales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: kCyan,
        scaffoldBackgroundColor: kFondo,
      ),
      home: const HomePage(),
    );
  }
}
