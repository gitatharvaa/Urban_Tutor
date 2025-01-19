import 'package:flutter/material.dart';
import 'home page screen/main_home_page.dart';
import 'classroom_screen.dart';
import 'category screen/category_screen.dart';

class HomePage extends StatefulWidget {
  final String token;  // Change to non-nullable String
  const HomePage({required this.token, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    const MainHomePage(),
    const ClassroomScreen(),
    const CategoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Classroom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
        ],
      ),
    );
  }
}