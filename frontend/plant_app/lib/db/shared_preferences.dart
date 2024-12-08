import 'dart:convert';
import 'package:plant_app/models/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService{
  static Future setLoginDetails(LoginResponseModel? loginResponseModel) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString('login_details', loginResponseModel.toString().isNotEmpty ? jsonEncode(loginResponseModel!.tojson(),) : '');
  }

  static Future loginDetails() async {
    final sharedPref = await SharedPreferences.getInstance();

    if(sharedPref.getString('login_details').toString().isNotEmpty && sharedPref.getString('login_details') != null){
      return LoginResponseModel.fromJson(jsonDecode(sharedPref.getStringList('login_details').toString()));
    }
  }

  static Future<bool> isLoggedin() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString('login_details') != null ? true : false;
  }

  static Future<void> logOut() async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.clear();
  }
}