import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/screens/detail_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ApiService _apiService = ApiService();
  List<Plant> _favoritePlants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final favorites = await _apiService.getFavorites();
      setState(() {
        _favoritePlants = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری علاقه‌مندی‌ها: $e')),
        );
        print('Error: $e');
      }
    }
  }

  Widget _buildFavoritePlantItem(BuildContext context, Plant plant) {
    final ApiService apiService = ApiService();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(plant: plant),
          ),
        );
      },
      child: Container(
        height: 80.0,
        margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Constant.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${plant.price} تومان',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Lalezar',
                color: Constant.primaryColor,
                fontSize: 20.0,
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Constant.primaryColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  bottom: 5.0,
                  left: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    height: 80.0,
                    child: FutureBuilder<String>(
                      future: apiService.fetchPlantImage(plant.plantId!),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (imageSnapshot.hasError) {
                          return const Icon(Icons.error);
                        } else {
                          return Image.network(
                            imageSnapshot.data!,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5.0,
                  right: 80.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plant.category,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontFamily: 'iransans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        plant.plantName,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Yekan Bakh',
                          fontSize: 18.0,
                          color: Constant.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'علاقه‌مندی'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritePlants.isEmpty
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 30.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _favoritePlants.length,
                    itemBuilder: (context, index) {
                      final plant = _favoritePlants[index];
                      return _buildFavoritePlantItem(context, plant);
                    },
                  ),
                ),
    );
  }
}
