import 'package:flutter/material.dart';
import 'router.dart' as router;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // causes the debug banner to not be shown
      title: ('manual data input'),
      onGenerateRoute: router.generateRoute,
      initialRoute: 'login',

    );
  }
}


