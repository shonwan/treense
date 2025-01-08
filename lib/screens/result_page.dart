import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? _currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = "Location services are disabled.";
        });
        return;
      }

      // Request permissions if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = "Location permissions are permanently denied.";
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Error fetching location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed from HomePage
    final Map<String, dynamic> arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String result = arguments['result'] as String;
    final String imagePath = arguments['imagePath'] as String;

    // Define background and border color based on result
    Color backgroundColor = result == 'Healthy' ? Colors.green : Colors.red;
    Color borderColor = result == 'Healthy' ? Colors.green.shade700 : Colors.red.shade700;
    IconData resultIcon = result == 'Healthy' ? Icons.check_circle : Icons.error_rounded;
    Color resultTextColor = result == 'Healthy' ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.file(
                    File(imagePath),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 3),
                  ),
                  child: Icon(
                    resultIcon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'The Plant is: $result',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: resultTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_currentLocation != null)
                  Text(
                    'Current Location: $_currentLocation',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.cloud_upload, color: Colors.teal),
                      label: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.home, color: Colors.teal),
                      label: const Text(
                        'Home',
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
