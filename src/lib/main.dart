import 'package:flutter/material.dart';

import 'ui/scanner_screen.dart';

void main() {
  runApp(const EasyAssetsPocApp());
}

class EasyAssetsPocApp extends StatelessWidget {
  const EasyAssetsPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy_Assets — PoC E2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ScannerScreen(),
    );
  }
}
