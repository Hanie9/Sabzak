import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/providers/plant_provider.dart';
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
  String _selectedCategory = '';

  bool toggleIsFavorite(bool isFavorite) {
    return !isFavorite;
  }

  final ApiService apiService = ApiService();
  late Future<List<Plant>> futurePlants;
  late Future<List<Plant>> futureNewPlants;
  late Future<List<String>> futureImages;
  late Future<List<Category>> categories;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchPlants({String query = '', String category = ''}) async {
    try {
      final plants = apiService.fetchPlants(query: query, category: category);
      setState(() {
        futurePlants = plants;
        _selectedCategory = category;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _fetchCategories() async {
    try {
      categories = apiService.fetchCategories();
      setState(() {
        categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    futurePlants = apiService.fetchPlants();
    futureNewPlants = apiService.fetchPlants();
    _fetchCategories();
    futureImages = apiService.fetchImages();
  }

  Widget _buildProducts(
      Size size, PlantProvider value, intl.NumberFormat numberformat) {
    return FutureBuilder<List<Plant>>(
        future: futurePlants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    size: 50.0, color: Constant.primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('گیاهی وجود ندارد :('));
          } else {
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final plant = snapshot.data![index];
                  return GestureDetector(
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
                                onPressed: () async {
                                  try {
                                    if (plant.isFavorated) {
                                      await apiService
                                          .removeFromFavorites(plant.plantId!);
                                      setState(() {
                                        plant.isFavorated = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('از علاقه‌مندی‌ها حذف شد'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
                                      await apiService
                                          .addToFavorites(plant.plantId!);
                                      setState(() {
                                        plant.isFavorated = true;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                    print('Error: $e');
                                  }
                                },
                                icon: Icon(
                                  plant.isFavorated
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: Constant.primaryColor,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20.0,
                            right: 50.0,
                            bottom: 50.0,
                            left: 40.0,
                            child: FutureBuilder<String>(
                              future:
                                  apiService.fetchPlantImage((plant.plantId!)),
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
                                  return Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          imageSnapshot.data!,
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 10.0,
                            left: 10.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                '${numberformat.format(int.parse(plant.price.toString()))} تومان'
                                    .farsiNumber,
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
                            bottom: 30.0,
                            right: 5.0,
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
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) {
                          CartProvider().fetchCartItems();
                          CartProvider().cartItems;
                          return DetailPage(
                            plant: plant,
                          );
                        },
                      ));
                    },
                  );
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final plantProvider = Provider.of<PlantProvider>(context);
    intl.NumberFormat numberformat = intl.NumberFormat.decimalPattern('fa');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'خانه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          futurePlants;
          futureImages;
        },
        child: SingleChildScrollView(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mic,
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: TextField(
                              controller: _searchController,
                              textAlign: TextAlign.start,
                              onChanged: (value) {
                                _fetchPlants(query: value);
                              },
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              showCursor: false,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(right: 5.0),
                                  hintText: "جستجو",
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontFamily: 'iransans',
                                  )),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _fetchPlants(query: _searchController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                height: 70.0,
                width: size.width,
                child: FutureBuilder<List<Category>>(
                  future: categories,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingAnimationWidget.staggeredDotsWave(
                          size: 10.0, color: Constant.primaryColor);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('هیچ گروهی وجود ندارد');
                    } else {
                      List<Category> categories = snapshot.data!;
                      return ListView.builder(
                          itemCount: categories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected =
                                category.name == _selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _fetchPlants(
                                        category: categories[index].name);
                                  });
                                },
                                child: Text(
                                  "| ${category.name} |",
                                  style: TextStyle(
                                    fontFamily: 'Yekan Bakh',
                                    fontSize: 16.0,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w300,
                                    color: isSelected
                                        ? Constant.primaryColor
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  },
                ),
              ),
              // Product 1
              SizedBox(
                  height: size.height * 0.3,
                  child: _buildProducts(size, plantProvider, numberformat)),
              //new plants text
              Container(
                padding:
                    const EdgeInsets.only(right: 25.0, top: 20.0, bottom: 15.0),
                alignment: Alignment.centerRight,
                child: const Text(
                  'تمام گیاهان',
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
                      future: futureNewPlants,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                  size: 50.0, color: Constant.primaryColor));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('گیاهی وجود ندارد'));
                        } else {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return NewPlantWidget(
                                index: index,
                              );
                            },
                          );
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
