// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
// import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/models/rating.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class PlantRatingPage extends StatefulWidget {
  final Plant plant;
  const PlantRatingPage({super.key, required this.plant});

  @override
  State<PlantRatingPage> createState() => _PlantRatingPageState();
}

class _PlantRatingPageState extends State<PlantRatingPage> {

  final TextEditingController _reactionController = TextEditingController();
  bool _isLoading = false;
  double _userRating = 0.0;
  double? _averageRating;
  List<Rating>? _reactions;

  @override
  void initState() {
    _fetchRatings();
    super.initState();
  }

  void _clearForm() {
    _reactionController.clear();
    setState(() {
      _userRating = 0.0;
    });
  }

  void _fetchRatings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService().getRatings(widget.plant.plantId!);
      final reactions = response['reactions'] as List;
      setState(() {
        _averageRating = response['average_rating'];
        _reactions = reactions.map((r) => Rating.fromJson(r)).toList();
      });
    } catch (e) {
      print('Failed to fetch ratings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



   void _submitRating() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ApiService().ratePlant(
        Rating(
          rating: _userRating,
          plantId: widget.plant.plantId!,
          reaction: _reactionController.text,
        ),
      );
      _clearForm();
      _fetchRatings();
    } catch (e) {
      print('Failed to submit rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'نظرات'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _isLoading ? Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          size: 20.0,
          color: Colors.green
        )
      ) :
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                        RatingBar.builder(
                          initialRating: _userRating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _userRating = rating;
                              _fetchRatings();
                            });
                          },
                        ),
                        const SizedBox(height: 10.0),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextFormField(
                            maxLines: 6,
                            minLines: 1,
                            controller: _reactionController,
                            decoration: const InputDecoration(
                              labelText: 'نظر شما:',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: _submitRating,
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(width: 2, color: Constant.primaryColor),
                            overlayColor: Constant.primaryColor,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
                          ),
                          child: Text(
                            'ذخیره',
                            style: TextStyle(
                              color: Constant.primaryColor,
                              fontFamily: 'Yekan Bakh',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                        if (_averageRating != null) ...[
                           Row(
                             children: [
                              Icon(
                                Icons.star,
                                color: Constant.primaryColor,
                              ),
                               Text(
                                _averageRating.toString(),
                              ),
                            ],
                          ),
                        ],
                      ]
                    ),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _reactions?.length ?? 0,
                  itemBuilder: (context, index) {
                    final reaction = _reactions![index];
                    return ListTile(
                      title: Text(reaction.username!),
                      subtitle: Text(reaction.reaction!),
                        trailing: RatingBarIndicator(
                        rating: reaction.rating.toDouble(),
                        itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                      )
                    );
                  }
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}