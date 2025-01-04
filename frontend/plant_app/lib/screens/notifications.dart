import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  List<dynamic> _notifications = [];
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = true;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _isLoading ? Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _notifications.isNotEmpty ? 
          Directionality(
            textDirection: TextDirection.rtl,
            child: Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Container(
                    width: size.width,
                    margin: const EdgeInsets.only(bottom: 7.0, top: 7.0),
                    padding: const EdgeInsets.only(left: 10.0, top: 3.0),
                    decoration: BoxDecoration(
                      color: Constant.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          const Icon(
                            Icons.notifications
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            notification['notification_title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "iransans"
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        notification['notification_comment'],
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: "Yekan Bakh"
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ) : const Center(
            child: Text(
              "هیچ اطلاعیه‌ای وجود ندارد",
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
    ): const Center(
      child: CircularProgressIndicator(),
    );
  }
}