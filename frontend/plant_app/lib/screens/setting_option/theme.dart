import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/main.dart';
import 'package:provider/provider.dart';

class ThemeChooserPage extends StatefulWidget {
  const ThemeChooserPage({super.key});

  @override
  State<ThemeChooserPage> createState() => _ThemeChooserPageState();
}

class _ThemeChooserPageState extends State<ThemeChooserPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
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
                'زمینه‌ها',
                style: TextStyle(
                  fontFamily: 'iransans'
                ),
              ),
            ),
          ],
        ),
      ),
      body: SwitchListTile(
        value: themeNotifier.darkTheme,
        onChanged: (value) {
          themeNotifier.toggleTheme();
        },
        title: const Text(
          'زمینه سیاه',
          style: TextStyle(
            fontSize: 17.0,
            fontFamily: "Yekan Bakh",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}