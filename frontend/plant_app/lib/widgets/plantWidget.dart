// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/screens/detail_page.dart';
import 'package:plant_app/widgets/extensions.dart';

class NewPlantWidget extends StatelessWidget {
  final int  index;
  const NewPlantWidget({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    intl.NumberFormat numberformat = intl.NumberFormat.decimalPattern('fa');
    final ApiService apiService = ApiService();

    return Container(
      height: 80.0,
      width: size.width,
      margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
      decoration: BoxDecoration(
        color: Constant.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FutureBuilder<List<Plant>>(
      future: apiService.fetchPlants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
            color: Constant.primaryColor,
            size: 30.0,)
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No plants available'));
        } else {
          final plant = snapshot.data![index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, PageTransition(
                child: DetailPage(plantId: plant.plantId),
                type: PageTransitionType.bottomToTop,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${numberformat.format(int.parse(plant.price.toString()))} تومان'.farsiNumber,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
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
                        shape: BoxShape.circle
                      ),
                    ),
                    Positioned(
                      bottom: 5.0,
                      left: 0.0,
                      right: 0.0,
                      child: SizedBox(
                        height: 80.0,
                        child:  FutureBuilder<String>(
                          future: apiService.fetchPlantImage(plant.plantId),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (imageSnapshot.hasError) {
                              return const Icon(Icons.error);
                            } else {
                              return Image.network(imageSnapshot.data!);
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
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          plant.plantName,
                            style: TextStyle(
                              fontFamily: 'Yekan Bakh',
                              fontSize: 18.0,
                              color: Constant.blackColor,
                              ),
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ],
              ),
          );
          }
        },
      ),
    );
  }
}