import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/landing_page.dart';
import 'screens/result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadModel();  // Make sure the model is loaded before the app starts
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/result': (context) => ResultPage(),
      },
      initialRoute: '/',
    );
  }
}
