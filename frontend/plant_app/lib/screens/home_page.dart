import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/providers/shop_provider.dart';
import 'package:plant_app/screens/detail_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/extensions.dart';
import 'package:plant_app/widgets/plantWidget.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int selectedindex = 0;

  bool toggleIsFavorite(bool isFavorite){
    return !isFavorite;
  }

  final ApiService apiService = ApiService();
  late Future<List<Plant>> futurePlants;
  late Future<List<String>> futureImages;

  @override
  void initState() {
    super.initState();
    futurePlants = apiService.fetchPlants();
    futureImages = apiService.fetchImages();
  }


  Widget _buildProducts(Size size, PlantProvider value, intl.NumberFormat numberformat) {
  return FutureBuilder<List<Plant>>(
    future: futurePlants,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: LoadingAnimationWidget.staggeredDotsWave(
          size: 50.0,
          color: Constant.primaryColor
        ));
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('هیچ گیاهی وجود ندارد'));
      } else {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index){
            final plant = snapshot.data![index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return DetailPage(plantId: plant.plantId,);
                    },
                  )
                );
              },
              child: Container(
                width: 200.0,
                margin: const EdgeInsets.symmetric(horizontal: 18.0),
                decoration: BoxDecoration(
                  color: Constant.primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10.0,
                      right: 20.0,
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: IconButton(
                          onPressed: (){
                            
                          },
                          icon: Icon(
                            Icons.favorite_border_outlined,
                            color: Constant.primaryColor,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50.0,
                      right: 50.0,
                      bottom: 50.0,
                      left: 50.0,
                      child: FutureBuilder<String>(
                        future: apiService.fetchPlantImage(plant.plantId),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return LoadingAnimationWidget.staggeredDotsWave(
                              color: Constant.primaryColor,
                              size: 30.0,
                            );
                          } else if (imageSnapshot.hasError) {
                            return const Icon(Icons.error);
                          } else {
                            return Image.network(imageSnapshot.data!);
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 15.0,
                      left: 10.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0)
                        ),
                        child: Text(
                          '${numberformat.format(int.parse(plant.price.toString()))} تومان'.farsiNumber,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Yekan Bakh',
                            color: Constant.primaryColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15.0,
                      right: 15.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            plant.category,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'iransans',
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            plant.plantName,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Yekan Bakh',
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        }
      }
    );
  }


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    final plantProvider = Provider.of<PlantProvider>(context);
    intl.NumberFormat numberformat = intl.NumberFormat.decimalPattern('fa');

    final List<String> plantTypes = [
    '| پیشنهادی |',
    '| آپارتمانی |',    
    '| محل‌کار |', 
    '| گل باغچه ای |', 
    '| گل سمی |', 
  ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'خانه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Constant.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  width: size.width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                      ),
                      Expanded(
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: TextField(
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                            showCursor: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(right: 5.0),
                              hintText: "جستجو",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: TextStyle(
                                fontFamily: 'iransans',
                              )
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              height: 70.0,
              width: size.width,
              child: ListView.builder(
                reverse: true,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedindex = index;
                        });
                      },
                      child: Text(
                        plantTypes[index],
                        style: TextStyle(
                          fontFamily: 'Yekan Bakh',
                          fontSize: 16.0,
                          fontWeight: selectedindex == index ? FontWeight.bold : FontWeight.w300,
                          color: selectedindex == index ? Constant.primaryColor : null,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: plantTypes.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
            // Product 1
            SizedBox(
              height: size.height * 0.3,
              child: _buildProducts(size, plantProvider, numberformat)
            ),
            //new plants text
            Container(
              padding: const EdgeInsets.only(right: 25.0, top: 20.0, bottom: 15.0),
              alignment: Alignment.centerRight,
              child: const Text(
                'گیاهان جدید',
                style: TextStyle(
                  fontFamily: 'iransans',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //new plants product 2
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              height: size.height * (0.3),
              child: FutureBuilder<List<Plant>>(
              future: futurePlants,
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: LoadingAnimationWidget.staggeredDotsWave(
                    size: 50.0,
                    color: Constant.primaryColor
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No plants available'));
                } else {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      return NewPlantWidget(index: index,);
                      },
                    );
                  }
                }
              )
            ),
          ],
        ),
      ),
    );
  }
}