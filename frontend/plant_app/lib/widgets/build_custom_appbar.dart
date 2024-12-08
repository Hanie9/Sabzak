import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';

class BuildCustomAppbar extends StatelessWidget {
  final String appbarTitle;
  const BuildCustomAppbar({
    super.key, required this.appbarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.notifications,
            color: Constant.blackColor,
            size: 30.0,
          ),
          Text(
            appbarTitle,
            style: TextStyle(
              fontFamily: 'Yekan Bakh',
              color: Constant.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}