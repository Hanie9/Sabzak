import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';

class CustomFormField extends StatelessWidget {

  final String? Function(String?)? validator;
  final TextEditingController controller;
  final bool obsecuretext;
  final Function(String)? onChanged;
  final TextDirection textDirection;
  final String lableName;


  const CustomFormField({
    super.key,
    this.validator,
    this.onChanged,
    this.obsecuretext = false,
    required this.lableName,
    this.textDirection = TextDirection.rtl,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        obscureText: obsecuretext,
        keyboardType: TextInputType.emailAddress,
        onChanged: onChanged,
        cursorColor: Constant.primaryColor,
        style: const TextStyle(
          fontFamily: 'Yekan Bakh',
          fontSize: 20.0,
          height: 2.0,
        ),
        textDirection: textDirection,
        decoration: InputDecoration(
          hintTextDirection: TextDirection.rtl,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constant.primaryColor,
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          label: Text(
            lableName,
            style: TextStyle(
              fontFamily: 'Lalezar',
              fontSize: 20.0,
              color: Constant.primaryColor,
            ),
          ),
          errorStyle: const TextStyle(
            fontFamily: 'Yekan Bakh',
          ),
        ),
        validator: validator,
      ),
    );
  }
}