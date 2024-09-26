import 'package:flutter/material.dart';
import 'package:scanning/camera.dart';
import 'package:scanning/gallery.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyTabBar(),
    );
  }
}

class MyTabBar extends StatefulWidget {
  @override
  _MyTabBarState createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
   // CameraTab(),
   // GalleryTab(),
    CamApp(),
    GalleryApp(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('scanning'),
          backgroundColor: Color.fromARGB(255, 236, 159, 4),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            tabs: [
              Tab(
                icon: Icon(Icons.camera),
              ),
              Tab(
                icon: Icon(Icons.photo),
              ),
            ],
          ),
        ),
        body: _tabs[_currentIndex],
      ),
    );
  }
}




