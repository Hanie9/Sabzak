import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/users_model.dart';
import 'package:shamsi_date/shamsi_date.dart';

class Detailuserpage extends StatefulWidget {
  final Users user;
  const Detailuserpage({super.key, required this.user});

  @override
  State<Detailuserpage> createState() => _DetailuserpageState();
}

class _DetailuserpageState extends State<Detailuserpage> {

  String convertToShamsi(DateTime date) {
    final Jalali jalaliDate = Jalali.fromDateTime(date);
    return '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return FutureBuilder<List<Users>>(
      future: apiService.getUsers(),
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
          return const Center(child: Text('کاربر وجود ندارد :('));
        } else {
          return Scaffold(
            body: Stack(
              children: [
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
                      const Text(
                        "کاربر",
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: Constant.primaryColor,
                              width: 2.0,
                            )
                          ),
                          child: Text(
                            "نام و نام خانوادگی: ${widget.user.firstName} ${widget.user.lastName}",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Yekan Bakh",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: Constant.primaryColor,
                              width: 2.0,
                            )
                          ),
                          child: Text(
                            "نام کاربری: ${widget.user.username}",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Yekan Bakh",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: Constant.primaryColor,
                              width: 2.0,
                            )
                          ),
                          child: Text(
                            "ایمیل: ${widget.user.email}",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Yekan Bakh",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: Constant.primaryColor,
                              width: 2.0,
                            )
                          ),
                          child: Text(
                            "تاریخ ثبت نام: ${convertToShamsi(widget.user.registrationDate)}",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Yekan Bakh",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}