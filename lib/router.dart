import 'package:flutter/material.dart';
import 'login.dart';
import 'settings.dart';
import 'input.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => SettingsRoute());
    case 'settings':
      return MaterialPageRoute(builder: (context) => SettingsRoute());
    case 'login':
      return MaterialPageRoute(builder: (context) => LoginRoute());
    case 'input':
      return MaterialPageRoute(builder: (context) => InputRoute());
    default:
      return MaterialPageRoute(builder: (context) => LoginRoute());
  }
}