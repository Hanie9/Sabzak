import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class RemovePlantsScreen extends StatefulWidget {
  const RemovePlantsScreen({super.key});

  @override
  State<RemovePlantsScreen> createState() => _RemovePlantsScreenState();
}

class _RemovePlantsScreenState extends State<RemovePlantsScreen> {
  late Future<List<Plant>> futurePlants;
  final ApiService apiService = ApiService();

    @override
  void initState() {
    super.initState();
    futurePlants = apiService.fetchPlants();
  }

  Future<void> _refreshplants()async{
    setState(() {
      futurePlants = apiService.fetchPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'حذف گیاه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshplants,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, right: 10.0, left: 10.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: FutureBuilder<List<Plant>>(
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
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final plant = snapshot.data![index];
                      return Card(
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(
                            plant.plantName,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Yekan Bakh",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'گروه: ${plant.category}',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontFamily: "iransans",
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Constant.primaryColor),
                            onPressed: () async {
                              try {
                                await apiService.deletePlant(plant.plantId!);
                                _refreshplants();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('گیاه با موفقیت حذف شد')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('متاسفانه مشکلی وجود دارد. گیاه حذف نشد :(')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
