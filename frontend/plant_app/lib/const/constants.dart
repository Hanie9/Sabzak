import 'package:flutter/material.dart';

class Serverinfo {
  // Android emulator: use 10.0.2.2 to reach host machine's localhost.
  // Physical device: use your PC's LAN IP (e.g. http://192.168.1.x:8888/).
  static String baseURL = 'http://10.0.2.2:8888/';

  // API end points
  static String plantURL = 'plants';
  static String createuserURL = 'sign_up';
  static String loginuserURL = 'login';
}

class Constant {
  static Color primaryColor = const Color(0xFF296e48);
  static Color blackColor = Colors.black54;
}
