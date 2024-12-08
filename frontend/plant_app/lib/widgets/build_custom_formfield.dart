import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/widgets/extensions.dart';

class BuildCustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextDirection formFieldtextDirection;
  final String labelName;

  const BuildCustomFormField({
    super.key,
    required this.controller,
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


class CustomValidator {
  static String? fieldMustComplete(String? value) {
    if (value.toString().isEmpty) {
      return 'این فیلد باید تکمیل شود';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value.toString().isEmpty) {
      return 'این فیلد باید تکمیل شود';
    } else if (!value!.isValidPassword) {
      // NABEGHEHA.COM
      return 'پسورد قوی نمی باشد';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value.toString().isEmpty) {
      return 'این فیلد باید تکمیل شود';
    } else if (!value!.isValidEmail) {
      return 'فرمت ایمیل صحیح نیست';
    }
    return null;
  }
}