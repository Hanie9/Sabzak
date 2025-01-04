import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';

class BuildCustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final int? maxlines;
  final int? minlines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextDirection formFieldtextDirection;
  final String labelName;

  const BuildCustomFormField({
    super.key,
    required this.controller,
    this.maxlines,
    this.minlines,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.formFieldtextDirection = TextDirection.rtl,
    required this.labelName,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        keyboardType: keyboardType,
        minLines: minlines,
        maxLines: maxlines,
        obscureText: obscureText,
        onChanged: onChanged,
        controller: controller,
        cursorColor: Constant.primaryColor,
        style: const TextStyle(
          fontFamily: 'YekanBakh',
          fontSize: 20.0,
          height: 2.0,
        ),
        textDirection: formFieldtextDirection,
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            fontFamily: 'YekanBakh',
          ),
          hintTextDirection: TextDirection.rtl,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constant.primaryColor,
              width: 1.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 15.0,
          ),
          label: Text(
            labelName,
            style: TextStyle(
              fontFamily: 'Lalezar',
              fontSize: 20.0,
              color: Constant.primaryColor,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}