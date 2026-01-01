import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/add_notifications.dart';
import 'package:plant_app/screens/add_plants_screen.dart';
import 'package:plant_app/screens/edit_price_plants.dart';
import 'package:plant_app/screens/remove_plants_screen.dart';
import 'package:plant_app/screens/show_users_screen.dart';
import 'package:plant_app/screens/reports_page.dart';
import 'package:plant_app/screens/create_user_page.dart';
import 'package:plant_app/screens/root.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

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
  final ApiService _apiService = ApiService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    selectedImage = _getRandomImage();
  }

  Future<void> _backupDatabase() async {
    setState(() {
      _isBackingUp = true;
    });
    try {
      final filePath = await _apiService.backupDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('پشتیبان‌گیری با موفقیت انجام شد. فایل در: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در پشتیبان‌گیری: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _restoreDatabase() async {
    setState(() {
      _isRestoring = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sql'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _apiService.restoreDatabase(filePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('بازگردانی پایگاه داده با موفقیت انجام شد'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isRestoring = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بازگردانی: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
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
      body: Stack(children: [
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
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const ShowUsersScreen();
                            },
                          ));
                        },
                        child: const Text(
                          "کاربران",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const AddNotifications();
                            },
                          ));
                        },
                        child: const Text(
                          "افزودن اطلاعیه",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
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
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const AddPlantsScreen();
                            },
                          ));
                        },
                        child: const Text(
                          "اضافه کردن گیاه",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const RemovePlantsScreen();
                            },
                          ));
                        },
                        child: const Text(
                          "حذف گیاه",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
                  )
                ],
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return EditPricePage();
                      },
                    ));
                  },
                  child: const Text(
                    "به‌روزرسانی قیمت گیاهان",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "iransans",
                      fontSize: 20.0,
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: _isBackingUp ? null : _backupDatabase,
                        child: _isBackingUp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "پشتیبان‌گیری",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "iransans",
                                  fontSize: 20.0,
                                ),
                              )),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: _isRestoring ? null : _restoreDatabase,
                        child: _isRestoring
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "بازگردانی",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "iransans",
                                  fontSize: 20.0,
                                ),
                              )),
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
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const ReportsPage();
                            },
                          ));
                        },
                        child: const Text(
                          "گزارش‌ها",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constant.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return const CreateUserPage();
                            },
                          ));
                        },
                        child: const Text(
                          "ایجاد کاربر",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "iransans",
                            fontSize: 20.0,
                          ),
                        )),
                  ),
                ],
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const RootPage();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "فروشگاه",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "iransans",
                      fontSize: 20.0,
                    ),
                  )),
              Image.asset(
                selectedImage,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
