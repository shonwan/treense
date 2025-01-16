import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? _currentLocation;
  bool isLoading = false;  // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = "Location services are disabled.";
        });
        return;
      }

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get the human-readable address using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentLocation =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _currentLocation = "Unable to determine location name.";
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Error fetching location: $e";
      });
    }
  }

  Future<void> _uploadToSupabase(String imagePath, String result) async {
    setState(() {
      isLoading = true;  // Start loading when the upload starts
    });

    try {
      final file = File(imagePath);
      final fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = Supabase.instance.client.storage;
      await storage.from('plant-images').upload(fileName, file);


      // Get the public URL for the uploaded image
      final imageUrl = storage.from('plant-images').getPublicUrl(fileName);

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Get location

      final latlong = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";

      // Insert data into the 'plant_classifications' table
      final data = {
        'image_url': imageUrl,
        'classification': result,
        'location': latlong,
      };

      await Supabase.instance.client
          .from('plant_classifications')
          .insert(data);


      // Notify the user of success
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Image uploaded and classification saved successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;  // Stop loading after the upload is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String result = arguments['result'] as String;
    final String imagePath = arguments['imagePath'] as String;

    Color backgroundColor = result == 'Healthy' ? Colors.green : Colors.red;
    Color borderColor = result == 'Healthy' ? Colors.green.shade700 : Colors.red.shade700;
    IconData resultIcon = result == 'Healthy' ? Icons.check_circle : Icons.error_rounded;
    Color resultTextColor = result == 'Healthy' ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      extendBodyBehindAppBar: true, // Ensures the AppBar overlays the body
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No shadow
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Adjust padding for logo
          child: Image.asset(
            'assets/logo.png', // Path to your logo image
            fit: BoxFit.contain, // Ensures the logo fits properly
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.green],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers the content horizontally
                  crossAxisAlignment: CrossAxisAlignment.center, // Centers the content vertically
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                        border: Border.all(color: borderColor, width: 3),
                      ),
                      child: Icon(
                        resultIcon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20), // Horizontal spacing between the icon and the text
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8), // Background color with transparency
                        borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        border: Border.all(color: resultTextColor, width: 3), // Border with color
                      ),
                      child: Text(
                        'The Plant is: $result',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: resultTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                if (_currentLocation != null)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),  // Background color with transparency
                      borderRadius: BorderRadius.circular(12.0),  // Rounded corners
                      border: Border.all(color: Colors.teal, width: 2),  // Border color and thickness
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,  // Location icon
                              color: Colors.red,
                              size: 24,  // Icon size
                            ),
                            const SizedBox(width: 8),  // Space between icon and text
                            Text(
                              'Current Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,  // Color for title
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentLocation?.replaceAll(",", "\n") ?? "Unknown Location",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,  // Color for the actual location
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null  // Disable the button while loading
                          : () async {
                        // Upload to Supabase
                        await _uploadToSupabase(imagePath, result);
                      },
                      icon: isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        strokeWidth: 2,
                      )
                          : const Icon(Icons.cloud_upload, color: Colors.teal),
                      label: Text(
                        isLoading ? 'Uploading...' : 'Upload',
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
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
                        Navigator.pop(context);
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
