import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/setting_option/aboutus.dart';
import 'package:plant_app/screens/setting_option/feedback.dart';
import 'package:plant_app/screens/setting_option/language.dart';
import 'package:plant_app/screens/setting_option/theme.dart';
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
        backgroundColor: Constant.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Positioned(
              left: 0.0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                ),
              ),
            ),
            const Positioned(
              right: 0.0,
              child: Text(
                'تنظیمات',
                style: TextStyle(
                  fontFamily: 'iransans'
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, PageTransition(child: const Language(), type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.language,
                title: 'زبان‌ها',
                ),
              ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, PageTransition(child: const ThemeChooserPage(), type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.color_lens_outlined,
                title: 'زمینه‌',
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, PageTransition(child: const About_Us(), type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.info_outline,
                title:'درباره ما' ,
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, PageTransition(child: const feedback(), type: PageTransitionType.bottomToTop));
              },
              child: const BuildOptions(
                icon: Icons.feedback_outlined,
                title: 'بازخورد‌های شما',
              ),
            ),
          ],
        ),
      ),
    );
  }
}