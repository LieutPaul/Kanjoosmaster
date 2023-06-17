import 'package:kanjoosmaster/screens/daily_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DailyPage(),
    Center(child: Text("Stats")),
    Center(child: Text("Profile"))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: navBar(),
          ),
        ),
      ),
    );
  }

  GNav navBar() {
    return GNav(
      rippleColor: Colors.grey[300]!,
      hoverColor: Colors.grey[100]!,
      gap: 8,
      activeColor: Colors.black,
      iconSize: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      duration: const Duration(milliseconds: 400),
      tabBackgroundColor: Colors.grey[100]!,
      color: Colors.white,
      tabs: const [
        GButton(
          icon: Icons.calendar_month,
          iconColor: Colors.white,
          textColor: Colors.black,
          text: 'Daily',
        ),
        GButton(
          icon: Icons.bar_chart,
          iconColor: Colors.white,
          textColor: Colors.black,
          text: 'Stats',
        ),
        GButton(
          icon: Icons.person,
          iconColor: Colors.white,
          textColor: Colors.black,
          text: 'Profile',
        ),
      ],
      selectedIndex: _selectedIndex,
      onTabChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
