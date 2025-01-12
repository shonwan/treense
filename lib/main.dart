import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_page.dart';
import 'screens/landing_page.dart';
import 'screens/result_page.dart';

const supabaseUrl = 'https://zjvbmahavecgovtgjkch.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdmJtYWhhdmVjZ292dGdqa2NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMDM0MDQsImV4cCI6MjA0ODY3OTQwNH0.s6D59MWDEeEAKUnAco7_RSoLjbkRbivqhJaMmVpttpQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Make sure the model is loaded before the app starts
  await loadModels();

  // Request location permission when the app starts
  bool locationPermissionGranted = await _requestLocationPermission();

  if (!locationPermissionGranted) {
    // If location permission is denied, show a message or handle it
    print("Location permission denied, unable to proceed.");
    // You could show a dialog or redirect to a different page, if needed
  }

  runApp(MyApp());
}

Future<bool> _requestLocationPermission() async {
  // Check if the location service is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // If location services are not enabled, show a message or ask user to enable it
    print("Location services are disabled. Please enable them.");
    return false;
  }

  // Check the current permission status
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    // Request permission if it's denied
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // If permission is still denied after request
      print("Location permission denied.");
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      // If permission is denied forever, inform the user
      print("Location permission denied forever.");
      return false;
    }
  } else if (permission == LocationPermission.deniedForever) {
    // Handle the case where the user has denied permission forever
    print("Location permission denied forever.");
    return false;
  }

  // Permission is granted
  print("Location permission granted.");
  return true;
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
