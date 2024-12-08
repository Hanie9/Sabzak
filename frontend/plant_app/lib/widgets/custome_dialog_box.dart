import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';

class CustomDialogBox{
  static void showMessage(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    final VoidCallback onPressed,
  ){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: false,
            child: AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lalezar',
                ),
              ),
              content: SingleChildScrollView(
                child: Text(
                  message,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'Yekan Bakh',
                    fontSize: 16.0
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontFamily: 'Yekan Bakh',
                      color: Constant.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}