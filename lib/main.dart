import 'package:flutter/material.dart';
import 'package:ubimap/Clases/dataBase.dart';
import 'package:ubimap/screens/first.dart';
import 'package:ubimap/screens/second.dart';
import 'package:ubimap/screens/third.dart';
import 'package:ubimap/styles/Colors.dart';
import 'globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await clearAllPins();
  await loadPins();
  runApp(const MyApp());
}

Future<void> clearAllPins() async {
  try{
    await DBHelper.deleteAllPins();
    await clearPinsFromSharedPreferences();
    await clearPinsFromCSV();
    print("Todos los pines han sido borrados exitosamente.");
  }catch (e){
    print("Error borrando los pines: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UbiMAP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.grey
      ),
      home: const MyHomePage(title: 'UbiMAP'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.lightOrange,
        ),
        body: const TabBarView(
          children: [
            FirstPage(),
            SecondPage(),
            ThirdPage(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.star), text: 'Map'),
            Tab(icon: Icon(Icons.person), text: 'Coordinates'),
          ],
        ),
      ),
    );
  }
}
