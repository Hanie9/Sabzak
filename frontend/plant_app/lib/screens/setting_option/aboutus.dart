import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';

class About_Us extends StatefulWidget {
  const About_Us({super.key});

  @override
  State<About_Us> createState() => _About_UsState();
}

class _About_UsState extends State<About_Us> {
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
                'درباره ما',
                style: TextStyle(
                  fontFamily: 'iransans'
                ),
              ),
            ),
          ],
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ماموریت ما',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Yekan Bakh",
              ),
            ),
            SizedBox(height: 10),
            Text(
             'ماموریت ما کمک به مردم برای کشف زیبایی گیاهان و مزایایی است که آنها می توانند به زندگی روزمره ما بیاورند.',
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: "iransans",
              ),
            ),
            SizedBox(height: 40),
            Text(
              'ما چه کسانی هستیم؟',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Yekan Bakh",
              ),
            ),
            SizedBox(height: 10),
            Text(
              'ما تیمی از علاقه مندان به گیاهان هستیم که به قدرت سبز برای آوردن انرژی مثبت و تعادل به زندگی اعتقاد داریم.',
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: "iransans",
              ),
            ),
          ],
        ),
      ),
    );
  }
}