import 'package:flutter/material.dart';
import 'components/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Millenium',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
