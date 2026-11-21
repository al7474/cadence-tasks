// Keep compatibility with the declared Flutter 3.27 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadence Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Cadence Tasks'),
          ),
        ),
      ),
    );
  }
}
