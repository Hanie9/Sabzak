import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/screens/cart_page.dart';
import 'package:plant_app/screens/favorite_page.dart';
import 'package:plant_app/screens/home_page.dart';
import 'package:plant_app/screens/profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();

  static _RootPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_RootPageState>();
  }
}

class _RootPageState extends State<RootPage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  void navigateToCartTab() {
    _controller.jumpToTab(2);
  }

  List<Plant> favorites = [];
  List<Plant> mycarts = [];

  List<Widget> pages() {
    return [
      const HomePage(),
      const FavoritePage(),
      const CartPage(),
      const ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: 'Home',
        activeColorPrimary: Constant.primaryColor,
        inactiveColorPrimary: Colors.black.withOpacity(0.5),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite),
        title: 'Favorite',
        activeColorPrimary: Constant.primaryColor,
        inactiveColorPrimary: Colors.black.withOpacity(0.5),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.local_mall),
        title: 'Cart',
        activeColorPrimary: Constant.primaryColor,
        inactiveColorPrimary: Colors.black.withOpacity(0.5),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_3),
        title: 'Profile',
        activeColorPrimary: Constant.primaryColor,
        inactiveColorPrimary: Colors.black.withOpacity(0.5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PersistentTabView(
      context,
      screens: pages(),
      navBarHeight: 51,
      controller: _controller,
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white10,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white10,
      ),
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          )),
      navBarStyle: NavBarStyle.style12,
    ));
  }
}
