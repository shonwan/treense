import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

final ImagePicker _picker = ImagePicker();
late Interpreter plantDetectorInterpreter;
late Interpreter healthCheckerInterpreter;


// Load both models
Future<void> loadModels() async {
  try {
    plantDetectorInterpreter = await Interpreter.fromAsset('assets/plant_modelH5.tflite');
    healthCheckerInterpreter = await Interpreter.fromAsset('assets/health_modelH5.tflite');
    print('Models loaded successfully.');
  } catch (e) {
    print('Error loading models: $e');
  }
}

// Function to pick an image
Future<File?> pickImageFromSource(ImageSource source) async {
  try {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}

// Preprocess the image
Future<List<List<List<List<double>>>>> preprocessImage(File imageFile, List<int> inputShape) async {
  try {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) return [];

    int inputHeight = inputShape[1];
    int inputWidth = inputShape[2];
    img.Image resizedImage = img.copyResize(image, width: inputWidth, height: inputHeight);

    List<List<List<List<double>>>> input = List.generate(
      1,
          (i) => List.generate(
        inputHeight,
            (j) => List.generate(
          inputWidth,
              (k) {
            int pixel = resizedImage.getPixel(k, j);
            return [
              img.getRed(pixel) / 255.0,
              img.getGreen(pixel) / 255.0,
              img.getBlue(pixel) / 255.0
            ];
          },
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );

    return input;
  } catch (e) {
    print('Error during preprocessing: $e');
    return [];
  }
}

// Function to classify if the image is a plant
Future<bool> isPlant(File imageFile) async {

  try {
    // Get input shape of the model
    var inputShape = plantDetectorInterpreter.getInputTensor(0).shape; // Example: [1, 180, 180, 3]

    // Preprocess image and reshape it to match input shape
    var input = await preprocessImage(imageFile, inputShape);
    if (input.isEmpty) return false;

    // Prepare the output tensor
    var outputShape = plantDetectorInterpreter.getOutputTensor(0).shape; // Example: [1, 1]
    var output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    // Run inference
    plantDetectorInterpreter.run(input, output);

    // Access the probability from the output
    double probability = output[0][0]; // Accessing the single value in the [1, 1] output

    // Interpret the result based on thresholding
    if (probability > 0.5) {
      print('Image classified as Not Plant (Probability: ${probability.toStringAsFixed(2)})');
      return false;
    } else {
      print('Image classified as Plant (Probability: ${(1 - probability).toStringAsFixed(2)})');
      return true;
    }
  } catch (e) {
    print('Error classifying image: $e');
    return false;
  }
}

// Function to check the health status of the plant
Future<Map<String, dynamic>> checkPlantHealth(File imageFile) async {
  try {
    var inputShape = healthCheckerInterpreter.getInputTensor(0).shape; 
    var input = await preprocessImage(imageFile, inputShape);
    if (input.isEmpty) return {'result': 'empty', 'confidence': 0.0};
    var outputShape = healthCheckerInterpreter.getOutputTensor(0).shape; 
    var output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    healthCheckerInterpreter.run(input, output);

    double probability = output[0][0]; 
    double confidence = probability > 0.5 ? probability : 1 - probability;

    if (probability > 0.5) {
      print('Image classified as Unhealthy (Confidence: ${confidence.toStringAsFixed(2)})');
      return {'result': 'Unhealthy', 'confidence': confidence};
    } else {
      print('Image classified as Healthy (Confidence: ${confidence.toStringAsFixed(2)})');
      return {'result': 'Healthy', 'confidence': confidence};
    }
  } catch (e) {
    print('Error classifying image: $e');
    return {'result': 'Unhealthy', 'confidence': 0.0}; 
  }
}


class HomePage extends StatelessWidget {
  Future<void> navigateToResultPage(BuildContext context, String result, double confidence, String imagePath) async {
    await Navigator.pushNamed(
      context,
      '/result',
      arguments: {'result': result, 'confidence': confidence, 'imagePath': imagePath},
    );
  }

  @override
  Widget build(BuildContext context) {
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
                ElevatedButton(
                  onPressed: () async {
                    File? imageFile = await pickImageFromSource(ImageSource.camera);
                    if (imageFile != null) {
                      bool isPlantImage = await isPlant(imageFile);
                      if (isPlantImage) {
                        Map<String, dynamic> resultData = await checkPlantHealth(imageFile);
                        String result = resultData['result'];
                        double confidence = resultData['confidence'];
                        navigateToResultPage(context, result, confidence, imageFile.path);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Rounded corners
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'Warning',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'The selected image is not a falcata plant. Please try again with a valid image.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // A modern and vibrant background color
                    foregroundColor: Colors.white, // Text color for better contrast
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0), // Spacious padding
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // More rounded corners for a sleek look
                    ),
                    elevation: 5, // Adds a subtle shadow for depth
                    shadowColor: Colors.black54, // Shadow color for better visibility
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 22, color: Colors.white), // Add an icon for better visual context
                      SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Capture Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    File? imageFile = await pickImageFromSource(ImageSource.gallery);
                    if (imageFile != null) {
                      bool isPlantImage = await isPlant(imageFile);
                      if (isPlantImage) {
                        Map<String, dynamic> resultData = await checkPlantHealth(imageFile);
                        String result = resultData['result'];
                        double confidence = resultData['confidence'];
                        navigateToResultPage(context, result, confidence, imageFile.path);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Rounded corners
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'Warning',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'The selected image is not a falcata plant. Please try again with a valid image.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Eye-catching background color
                    foregroundColor: Colors.white, // Text color for better contrast
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0), // Spacious padding
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // More rounded corners for a modern design
                    ),
                    elevation: 5, // Adds subtle depth with shadow
                    shadowColor: Colors.black54, // Shadow color for visibility
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image , size: 22, color: Colors.white), // Icon for context
                      SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Gallery Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
