import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/screens/setting_option/aboutus.dart';
import 'package:plant_app/screens/setting_option/feedback.dart';
import 'package:plant_app/screens/setting_option/language.dart';
import 'package:plant_app/screens/change_password_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/profile_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'تنظیمات'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: const Language(),
                        type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.language,
                title: 'زبان‌ها',
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: const About_Us(),
                        type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.info_outline,
                title: 'درباره ما',
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: const feedback(),
                        type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.feedback_outlined,
                title: 'بازخورد‌های شما',
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: const ChangePasswordPage(),
                        type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.lock_outline,
                title: 'تغییر رمز عبور',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
