import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/add_plants_screen.dart';
import 'package:plant_app/screens/show_users_screen.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'ادمین'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constant.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return const ShowUsersScreen();
                    },
                  )
                );
              },
              child: const Text(
                "کاربران",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "iransans",
                  fontSize: 25.0,
                ),
              )
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constant.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return const AddPlantsScreen();
                    },
                  )
                );
              },
              child: const Text(
                "اضافه کردن گیاه",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "iransans",
                  fontSize: 25.0,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
