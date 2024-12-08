import 'package:flutter/material.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/plantWidget.dart';

class FavoritePage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final List<Plant> FavoritedPlants;
  // ignore: non_constant_identifier_names
  const FavoritePage({super.key, required this.FavoritedPlants});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'علاقه‌مندی'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: widget.FavoritedPlants.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100.0,
              child: Image.asset('assets/images/12_12.png'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'علاقه‌مندی‌ها',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'iransans',
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30.0),
        height: size.height * (0.5),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: widget.FavoritedPlants.length,
          itemBuilder: (context, index) {
            return NewPlantWidget(
              index: index,
            );
          },
        ),
      ),
    );
  }
}