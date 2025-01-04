import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/add_notifications.dart';
import 'package:plant_app/screens/add_plants_screen.dart';
import 'package:plant_app/screens/edit_price_plants.dart';
import 'package:plant_app/screens/remove_plants_screen.dart';
import 'package:plant_app/screens/show_users_screen.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> imagepath = [
    "assets/images/design2.png",
    "assets/images/design3.png",
    "assets/images/design4.png",
    "assets/images/design7.png",
    "assets/images/design8.png"
  ];

  String _getRandomImage() {
    final random = Random();
    return imagepath[random.nextInt(imagepath.length)];
  }

  late String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = _getRandomImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'ادمین'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton(
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
                            fontSize: 20.0,
                          ),
                        )
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return const AddNotifications();
                              },
                            )
                          );
                        },
                        child: const Text(
                          "افزودن اطلاعیه",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton(
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
                            fontSize: 20.0,
                          ),
                        )
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return const RemovePlantsScreen();
                              },
                            )
                          );
                        },
                        child: const Text(
                          "حذف گیاه",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return EditPricePage();
                        },
                      )
                    );
                  },
                  child: const Text(
                    "به‌روزرسانی قیمت گیاهان",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "iransans",
                      fontSize: 20.0,
                    ),
                  )
                ),
                Image.asset(
                  selectedImage,
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
