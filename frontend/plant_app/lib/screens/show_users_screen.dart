import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/users_provider.dart';
import 'package:plant_app/screens/detailUserpage.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:provider/provider.dart';

class ShowUsersScreen extends StatefulWidget {
  const ShowUsersScreen({super.key});

  @override
  State<ShowUsersScreen> createState() => _ShowUsersScreenState();
}

class _ShowUsersScreenState extends State<ShowUsersScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchusers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersprovider = Provider.of<UsersProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'کاربران'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Consumer<UsersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.users.isEmpty) {
            return const Center(
              child: Text(
                "هیچ کاربری وجود ندارد :(",
                style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: "Lalezar",
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: usersprovider.users.length,
                      itemBuilder: (context, index) {
                        final user = usersprovider.users[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return Detailuserpage(user: user,);
                                },
                              )
                            );
                          },
                          child: Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Container(
                            padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: Constant.primaryColor,
                                  width: 2.0,
                                )
                              ),
                              child: ListTile(
                                title: Text(
                                  "${user.firstName} ${user.lastName}",
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "iransans",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: user.isadmin ? 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "ادمین",
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: Constant.primaryColor,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.admin_panel_settings,
                                      size: 20.0,
                                      color: Constant.primaryColor,
                                    ),
                                  ],
                                ) : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "کاربر",
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          color: Constant.primaryColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.person,
                                        size: 20.0,
                                        color: Constant.primaryColor,
                                      ),
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            );
          }
        }
      ),
    );
  }
}