import 'package:flutter/material.dart';
import 'package:flutter_gokwik_example/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoKwik Payment Gateway',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
