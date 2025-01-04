import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPricePage extends StatefulWidget {
  @override
  _EditPricePageState createState() => _EditPricePageState();
}

class _EditPricePageState extends State<EditPricePage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://45.156.23.34:8000'));
  late Future<List<Plant>> _futurePlants;
  final _priceController = TextEditingController();
  ApiService apiService = ApiService();
  Plant? _selectedPlant;

  @override
  void initState() {
    super.initState();
    _futurePlants = apiService.fetchPlants();
  }

  Future<void> _updatePrice() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    if (_selectedPlant != null && _priceController.text.isNotEmpty) {
      try {
        final response = await _dio.patch('/edit_price/${_selectedPlant!.plantId}?updated_price=${int.parse(_priceController.text)}', 
          options: Options(headers: {'session_id': sessionId}),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('قیمت گیاه ${_selectedPlant!.plantName} به‌روزرسانی شد')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("قیمت گیاه ${_selectedPlant!.plantName} به‌روزرسانی نشد")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا یک گیاه را انتخاب کنید')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'به‌روزرسانی قیمت'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<Plant>>(
              future: _futurePlants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('هیچ گیاهی وجود ندارد'));
                } else {
                  return SingleChildScrollView(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<Plant>(
                              hint: const Text('انتخاب گیاه'),
                              value: _selectedPlant,
                              onChanged: (Plant? newValue) {
                                setState(() {
                                  _selectedPlant = newValue;
                                });
                              },
                              items: snapshot.data!.map<DropdownMenuItem<Plant>>((Plant plant) {
                                return DropdownMenuItem<Plant>(
                                  value: plant,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          FutureBuilder<String>(
                                            future: apiService.fetchPlantImage(plant.plantId!),
                                            builder: (context, imageSnapshot) {
                                              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                                return LoadingAnimationWidget.staggeredDotsWave(
                                                  size: 20.0,
                                                  color: Constant.primaryColor
                                                );
                                              } else if (imageSnapshot.hasError) {
                                                return const Icon(Icons.error);
                                              } else {
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: Container(
                                                    width: 40.0,
                                                    height: 30.0,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(imageSnapshot.data!),
                                                        fit: BoxFit.contain
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 10,),
                                          Text(plant.plantName)
                                        ],
                                      ),
                                      const Divider(
                                        thickness: 1.0, color: Colors.grey,
                                      ),
                                    ],
                                  )
                                );
                              }).toList(),
                            ),
                            BuildCustomFormField(
                              labelName: "قیمت جدید:",
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(width: 2, color: Constant.primaryColor),
                overlayColor: Constant.primaryColor,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
            ),
              onPressed: _updatePrice,
              child: Text(
                'به‌روزرسانی',
                style: TextStyle(
                  color: Constant.primaryColor,
                  fontFamily: 'Yekan Bakh',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
