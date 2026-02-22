import 'dart:ui';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/screens/plant_rating_page.dart';
import 'package:plant_app/screens/root.dart';
import 'package:plant_app/widgets/extensions.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final Plant plant;
  const DetailPage({super.key, required this.plant});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool toggleisselected(bool isSelected) {
    return !isSelected;
  }

  bool kharid = false;
  // int _rating = 0;
  double _averageRating = 0.0;
  final ApiService apiService = ApiService();

  Future<void> _fetchAverageRating() async {
    try {
      final response = await apiService.getRatings(widget.plant.plantId!);
      setState(() {
        _averageRating = response['average_rating'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch average rating')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCartItems();
    });
  }

  Future<void> _refreshbadge() async {
    setState(() {
      Provider.of<CartProvider>(context, listen: false).fetchCartItems();
      _fetchAverageRating();
    });
  }

  Widget _buildFloatingCartButton(
      BuildContext context, Size size, CartProvider cart) {
    return SizedBox(
      width: size.width * 0.9,
      height: 58.0,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _refreshbadge();
              final rootState = RootPage.of(context);
              Navigator.popUntil(context, (route) {
                if (route.isFirst) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    rootState?.navigateToCartTab();
                  });
                  return true;
                }
                return false;
              });
            },
            child: Container(
              height: 58.0,
              width: 58.0,
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
                isLabelVisible: cart.cartItems.isEmpty ? false : true,
                label: Text(
                  cart.cartItems.length.toString(),
                  style: const TextStyle(
                      fontFamily: 'Yekan Bakh',
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                child: Badge(
                  isLabelVisible: cart.cartItems.isEmpty ? false : true,
                  label: Text(
                    cart.cartItems.length.toString(),
                    style: const TextStyle(
                        fontFamily: 'Yekan Bakh',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_cart,
                      color: cart.cartItems.isEmpty
                          ? Colors.white
                          : Colors.green[900],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
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
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.primaryColor,
                  minimumSize: const Size(0, 58),
                ),
                onPressed: () {
                  cart.addToCart(widget.plant.plantId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      padding: const EdgeInsets.all(10.0),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      behavior: SnackBarBehavior.fixed,
                      content: Center(
                        child: Text(
                          'گیاه ${widget.plant.plantName} با موفقیت به سبد‌خرید اضافه شد',
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
          ),
        ],
      ),
    );
  }

  // loadBooleanValue() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     kharid = prefs.getBool('kharid') ?? false;
  //   });
  // }

  // saveBooleanValue(bool value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('kharid', value);
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<List<Plant>>(
        future: apiService.fetchPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
              color: Constant.primaryColor,
              size: 30.0,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('هیچ گیاهی وجود ندارد :('));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                Provider.of<CartProvider>(context, listen: false)
                    .fetchCartItems();
              },
              child: Scaffold(
                body: Stack(
                  children: [
                    //Appbar
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8.0,
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
                          GestureDetector(
                            onTap: () async {
                              try {
                                if (widget.plant.isFavorated) {
                                  await apiService.removeFromFavorites(
                                      widget.plant.plantId!);
                                  setState(() {
                                    widget.plant.isFavorated = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('از علاقه‌مندی‌ها حذف شد'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  await apiService
                                      .addToFavorites(widget.plant.plantId!);
                                  setState(() {
                                    widget.plant.isFavorated = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('به علاقه‌مندی‌ها اضافه شد'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطا: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                color: Constant.primaryColor.withOpacity(0.15),
                              ),
                              child: Icon(
                                widget.plant.isFavorated
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Constant.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 44.0,
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
                              top: 16.0,
                              left: 0.0,
                              child: SizedBox(
                                height: 350.0,
                                child: FutureBuilder<String>(
                                  future: apiService
                                      .fetchPlantImage(widget.plant.plantId!),
                                  builder: (context, imageSnapshot) {
                                    if (imageSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingAnimationWidget
                                          .staggeredDotsWave(
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
                              children: [
                                Positioned(
                                  top: 16.0,
                                  right: 0.0,
                                  child: SizedBox(
                                    height: 200.0,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 4, sigmaY: 4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                PlantFeature(
                                                  title: 'اندازه گیاه',
                                                  plantFeature:
                                                      widget.plant.size,
                                                ),
                                                PlantFeature(
                                                  title: 'رطوبت‌هوا',
                                                  plantFeature: widget
                                                      .plant.humidity
                                                      .toString(),
                                                ),
                                                PlantFeature(
                                                  title: 'دمای‌نگه‌داری',
                                                  plantFeature:
                                                      widget.plant.temperature,
                                                  valueTextDirection:
                                                      TextDirection.rtl,
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
                        padding: const EdgeInsets.only(
                            top: 56.0, right: 30.0, left: 20.0),
                        height: size.height * (0.5),
                        width: size.width,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                topRight: Radius.circular(30.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Constant.primaryColor,
                                      ),
                                      const SizedBox(
                                        width: 1.0,
                                      ),
                                      Text(
                                        _averageRating.toString(),
                                        style: TextStyle(
                                            color: Constant.primaryColor,
                                            fontSize: 18.0,
                                            fontFamily: "iransans",
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: PlantRatingPage(
                                                  plant: widget.plant,
                                                ),
                                                type: PageTransitionType
                                                    .bottomToTop,
                                              ),
                                            );
                                          },
                                          icon: ImageIcon(
                                            const AssetImage(
                                                "assets/images/chat3.png"),
                                            size: 25.0,
                                            color: Constant.primaryColor,
                                          )),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      // IconButton(
                                      //   onPressed: () {
                                      //     Navigator.push(context, PageTransition(
                                      //       child: PlantRatingPage(plant: widget.plant,),
                                      //       type: PageTransitionType.bottomToTop,
                                      //       ),
                                      //     );
                                      //   },
                                      //   icon: ImageIcon(
                                      //     const AssetImage("assets/images/alarm.png"),
                                      //     size: 25.0,
                                      //     color: Constant.primaryColor,
                                      //   )
                                      // ),
                                    ]),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.plant.plantName,
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
                                          child: Image.asset(
                                              'assets/images/7_7.png'),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          widget.plant.price
                                              .toString()
                                              .farsiNumber,
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
                            const SizedBox(height: 8.0),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 20.0 * 1.6 * 4,
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.plant.description!,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: Consumer<CartProvider>(
                  builder: (context, cart, _) =>
                      _buildFloatingCartButton(context, size, cart),
                ),
              ),
            );
          }
        });
  }
}

class PlantFeature extends StatelessWidget {
  final String title;
  final String plantFeature;
  final TextDirection? valueTextDirection;

  const PlantFeature({
    super.key,
    required this.title,
    required this.plantFeature,
    this.valueTextDirection,
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
          textDirection: valueTextDirection,
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
