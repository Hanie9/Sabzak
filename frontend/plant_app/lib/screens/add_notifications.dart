import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class AddNotifications extends StatefulWidget {
  const AddNotifications({super.key});

  @override
  State<AddNotifications> createState() => _AddNotificationsState();
}

class _AddNotificationsState extends State<AddNotifications> {
  final ApiService apiService = ApiService();
  final _notificationController = TextEditingController();
  final _notificationTitleController = TextEditingController();
  List<dynamic> _notifications = [];

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
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> _addNotification() async {
    final notification = _notificationController.text;
    final notificationTitle = _notificationTitleController.text;

    if (notification.isNotEmpty) {
      try {
        await apiService.addNotification(notification, notificationTitle);
        _notificationController.clear();
        _notificationTitleController.clear();
        _fetchNotifications();
      } catch (e) {
        print('Error adding notification: $e');
      }
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await apiService.deleteNotification(id);
      _fetchNotifications();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'افزودن اطلاعیه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Container(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _notificationTitleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان اطلاعیه:',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        maxLines: 6,
                        minLines: 1,
                        controller: _notificationController,
                        decoration: const InputDecoration(
                          labelText: 'اطلاعیه:',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _addNotification,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0,),
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
                      margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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
                                fontSize: 18.0,
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
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Yekan Bakh"
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Constant.primaryColor
                          ),
                          onPressed: () => _deleteNotification(notification['notification_id']),
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
      ),
    );
  }
}