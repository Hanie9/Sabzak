// import 'dart:convert';
// import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
// import 'package:plant_app/const/constants.dart';
// import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/users_model.dart';
import 'package:plant_app/screens/login_page.dart';
import 'package:plant_app/screens/notifications.dart';
import 'package:plant_app/screens/setting.dart';
import 'package:plant_app/screens/admin_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/profile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<Users>? _userProfile;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://45.156.23.34:8000'));
  final picker = ImagePicker();
  File? _image;
  String? _profileImageUrl;

  @override
  void initState(){
    _loadProfileImage();
    _userProfile = ApiService().fetchUserProfile();
    super.initState();
  }

  void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'اطلاعیه‌ها',
          ),
        ),
        content: const SizedBox(
          width: double.maxFinite,
          height: 250.0,
          child: Notifications(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'بستن',
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: "Yekan Bakh",
                color: Constant.primaryColor,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> _loadProfileImage() async {
    try {
      final profileUrl = await ApiService().fetchProfile();
      setState(() {
        _profileImageUrl = 'http://45.156.23.34:8000/$profileUrl';
      });
    } catch (e) {
      print(e);
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    await _uploadPhoto();
  }

  Future<void> _uploadPhoto() async {
    if (_image == null) return;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(_image!.path),
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.post(
        '/profiles/upload_profile',
        data: formData,
        options: Options(headers: {
          'session_id': sessionId,
        }),
      );
      if (response.statusCode == 200) {
        ApiService().fetchProfile();
        print('Photo uploaded successfully');
      } else {
        print('Failed to upload photo');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    await ApiService().clearSessionId(sessionId!);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) {
          return const LoginPage();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'پروفایل'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: FutureBuilder<Users>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No profile data found.'));
        } else {
          Users userProfile = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(20.0),
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                // profile image
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Constant.primaryColor.withOpacity(0.5),
                          width: 4.0,
                        )
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) ? NetworkImage(_profileImageUrl!) : null,
                        child: (_profileImageUrl == null || _profileImageUrl!.isEmpty) ? const Icon(Icons.person, size: 50) : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Constant.primaryColor,
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                // profile name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${userProfile.firstName} ${userProfile.lastName}',
                      style: const TextStyle(
                        fontFamily: 'iransans',
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    SizedBox(
                      height: 20.0,
                      child: Image.asset('assets/images/9_9.png'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                // profile email
                Text(
                  userProfile.email,
                  style: const TextStyle(
                    fontFamily: 'iransans',
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                // profile options
                SizedBox(
                  height: size.height * (0.4),
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Admin panel button (only for admins)
                      if (userProfile.isadmin)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, PageTransition(
                              child: const AdminScreen(),
                              type: PageTransitionType.fade,
                            ));
                          },
                          child: const BuildOptions(
                            icon: Icons.admin_panel_settings,
                            title: 'صفحه ادمین',
                          ),
                        ),
                      if (userProfile.isadmin)
                        const SizedBox(height: 10),
                      // back button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, PageTransition(
                            child: const Settings(),
                            type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: const BuildOptions(icon: Icons.settings, title: 'تنظیمات',),
                      ),
                      GestureDetector(
                        onTap: () {
                          showNotificationDialog(context);
                        },
                        child: const BuildOptions(
                          icon: Icons.notifications,
                          title: 'اطلاع رسانی‌ها',
                        ),
                      ),
                      const BuildOptions(icon: Icons.share, title: 'شبکه‌های اجتماعی',),
                      GestureDetector(
                        onTap: _logout,
                        child: const BuildOptions(icon: Icons.logout, title: 'خروج',)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          }
        },
      ),
    );
  }
}