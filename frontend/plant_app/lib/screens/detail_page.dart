import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/screens/cart_page.dart';
import 'package:plant_app/widgets/extensions.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final int plantId;
  const DetailPage({super.key, required this.plantId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  bool toggleisselected(bool isSelected){
    return !isSelected;
  }
  bool kharid = false;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    final cart = Provider.of<CartProvider>(context);
    final ApiService apiService = ApiService();
    
    return FutureBuilder<List<Plant>>(
      future: apiService.fetchPlants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                color: Constant.primaryColor,
                size: 30.0,
                )
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No plants available'));
            } else {
              final plant = snapshot.data!;
              return Scaffold(
                body: Stack(
                  children: [
                    //Appbar
                    Positioned(
                      top: 71.0,
                      left: 20.0,
                      right: 20.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            // x button
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                color: Constant.primaryColor.withOpacity(0.15),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Constant.primaryColor,
                              ),
                            ),
                          ),
                          // Like button
                          Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Constant.primaryColor.withOpacity(0.15),
                            ),
                            child: Icon(
                              plant[widget.plantId].isFavorated == true ? Icons.favorite : Icons.favorite_border,
                              color: Constant.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 100.0,
                      left: 20.0,
                      right: 20.0,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        width: size.width * (0.8),
                        height: size.height * (0.8),
                        child: Stack(
                          children: [
                            // product image
                            Positioned(
                              top: 30.0,
                              left: 0.0,
                              child: SizedBox(
                                height: 350.0,
                                child: FutureBuilder<String>(
                                  future: apiService.fetchPlantImage(widget.plantId),
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
                            ),
                            // plant feature
                            Stack(
                              children:[
                                Positioned(
                                  top: 30.0,
                                  right: 0.0,
                                  child: SizedBox(
                                    height: 200.0,
                                    child: Stack(
                                      children:[
                                        ClipRRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                PlantFeature(
                                                  title: 'اندازه گیاه',
                                                  plantFeature: plant[widget.plantId].size,
                                                ),
                                                PlantFeature(
                                                  title: 'رطوبت‌هوا',
                                                  plantFeature: plant[widget.plantId].humidity.toString(),
                                                ),
                                                PlantFeature(
                                                  title: 'دمای‌نگه‌داری',
                                                  plantFeature: plant[widget.plantId].temperature,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        padding: const EdgeInsets.only(top: 80.0, right: 30.0, left: 30.0),
                        height: size.height * (0.5),
                        width: size.width,
                        decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 30.0,
                                      color: Constant.primaryColor,
                                    ),
                                    Text(
                                      plant[widget.plantId].rating.toString().farsiNumber,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'Lalezar',
                                        color: Constant.primaryColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 23.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      plant[widget.plantId].plantName,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'Yekan Bakh',
                                        fontWeight: FontWeight.bold,
                                        color: Constant.primaryColor,
                                        fontSize: 27.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 19.0,
                                          child: Image.asset('assets/images/7_7.png'),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          plant[widget.plantId].price.toString().farsiNumber,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontFamily: 'Lalezar',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                            color: Constant.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            SingleChildScrollView(
                              child: Text(
                                plant[widget.plantId].description!,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  height: 1.6,
                                  fontFamily: 'iransans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: SizedBox(
                  width: size.width * 0.9,
                  height: 50.0,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, PageTransition(
                            child: const CartPage(),
                            type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0.0, 1.1),
                                blurRadius: 5.0,
                                color: Constant.primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                          child: Badge(
                            isLabelVisible: cart.items.isEmpty ? false : true,
                            label: Text(
                              cart.itemCount.toString(),
                              style: const TextStyle(
                                fontFamily: 'Yekan Bakh',
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shopping_cart,
                                color:  cart.items.isEmpty ? Colors.white : Colors.green[900],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      kharid == false ? Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Constant.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0.0, 1.1),
                                blurRadius: 5.0,
                                color: Constant.primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constant.primaryColor
                            ),
                            onPressed: () {
                              setState(() {
                                Provider.of<CartProvider>(context, listen: false).addItem(plant[widget.plantId]);
                                kharid = true;
                              });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      padding: const EdgeInsets.all(10.0),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(20.0))
                                      ),
                                      behavior: SnackBarBehavior.fixed,
                                      content: Center(
                                        child: Text(
                                          'گیاه ${plant[widget.plantId].plantName} با موفقیت به سبد‌خرید اضافه شد',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: 'iransans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                            child: const Text(
                              'افزودن‌به‌سبد‌خرید',
                              style: TextStyle(
                                fontFamily: 'iransans',
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ) :
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Constant.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0.0, 1.1),
                                blurRadius: 5.0,
                                color: Constant.primaryColor.withOpacity(0.3),
                              ),
                            ]
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constant.primaryColor
                            ),
                            onPressed: () {
                              setState(() {
                                final cartItem = cart.items[widget.plantId];
                                cart.removeItem(cartItem!.plant.plantId);
                                kharid = false;
                              });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      padding: const EdgeInsets.all(10.0),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(20.0))
                                      ),
                                      behavior: SnackBarBehavior.fixed,
                                      content: Center(
                                        child: Text(
                                          'گیاه ${plant[widget.plantId].plantName} با موفقیت از سبدخرید حذف شد',
                                          style: const TextStyle(
                                            fontFamily: 'iransans',
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                            child: const Text(
                              'حذف‌از‌سبد‌خرید',
                              style: TextStyle(
                                fontFamily: 'iransans',
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        );
      }
    }

class PlantFeature extends StatelessWidget {

  final String title;
  final String plantFeature;

  const PlantFeature({
    super.key, required this.title, required this.plantFeature,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Yekan Bakh',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          plantFeature,
          style: TextStyle(
            fontFamily: 'iransans',
            color: Constant.primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}