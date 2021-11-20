import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/themes/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';

import 'analytic_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List _screens = [
    const HomeTab(),
    const AnalyticTab(),
    const ProfileTab(),
  ];

  final List<BottomNavigationBarItem> _navigationBarItem = [
    const BottomNavigationBarItem(
      activeIcon: RadiantGradientMask(
        child: Icon(
          MyFlutterApp.home,
          color: Colors.white,
        ),
        colors: [
          Color(0xFFAA76FF),
          Color(0xFF4400D5),
        ],
      ),
      icon: Icon(MyFlutterApp.homeOutline),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      activeIcon: RadiantGradientMask(
        child: Icon(
          MyFlutterApp.pie,
          color: Colors.white,
        ),
        colors: [
          Color(0xFFAA76FF),
          Color(0xFF4400D5),
        ],
      ),
      icon: Icon(MyFlutterApp.pieOutline),
      label: 'Analytic',
    ),
    const BottomNavigationBarItem(
      activeIcon: RadiantGradientMask(
        child: Icon(
          MyFlutterApp.user,
          color: Colors.white,
        ),
        colors: [
          Color(0xFFAA76FF),
          Color(0xFF4400D5),
        ],
      ),
      icon: Icon(MyFlutterApp.userOutline),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationBarItem,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
