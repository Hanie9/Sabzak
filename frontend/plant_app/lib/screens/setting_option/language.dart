import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:plant_app/const/constants.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {

  final FlutterLocalization _localization = FlutterLocalization.instance;

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
                'زبان',
                style: TextStyle(
                  fontFamily: 'iransans'
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('English'),
                    onPressed: () {
                      _localization.translate('en');
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('persian'),
                    onPressed: () {
                      _localization.translate('fa');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}