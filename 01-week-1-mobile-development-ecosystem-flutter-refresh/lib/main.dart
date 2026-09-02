import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shield, size: 72),
            SizedBox(height: 16),
            Text('Helmi Rizqi Ramadhan', style: TextStyle(fontSize: 24)),
            Text('Pemrograman Mobile — Minggu 1'),
            Text('244107020107 - TI-3F'),
          ]),
        ),
      ),
    );
  }
}