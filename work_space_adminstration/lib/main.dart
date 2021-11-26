import 'package:flutter/material.dart';
import 'package:work_space_adminstration/map.dart';

void main() =>runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'work space administration',
      home: MapScreen()
    );
  }
}
