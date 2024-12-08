import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/setting.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              // profile image
              Container(
                width: 150.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Constant.primaryColor.withOpacity(0.5),
                    width: 5.0,
                  )
                ),
                child: const CircleAvatar(
                  radius: 65.0,
                  backgroundColor: Colors.transparent,
                  backgroundImage: ExactAssetImage('assets/images/10_10.jpg'),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              // profile name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'ساناز امینی',
                    style: TextStyle(
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
              const Text(
                'sanaz@gmail.com',
                style: TextStyle(
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
                    // back button
                    const BuildOptions(icon: Icons.person, title: 'پروفایل من',),
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
                    const BuildOptions(icon: Icons.notifications, title: 'اطلاع رسانی‌ها',),
                    const BuildOptions(icon: Icons.share, title: 'شبکه‌های اجتماعی',),
                    const BuildOptions(icon: Icons.logout, title: 'خروج',),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}