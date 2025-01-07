import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'result_page.dart';

final ImagePicker _picker = ImagePicker();
late Interpreter interpreter;

Future<void> loadModel() async {
  try {
    interpreter = await Interpreter.fromAsset('assets/plant_modelH5.tflite');
    print('Model loaded successfully.');
  } catch (e) {
    print('Error loading model: $e');
  }
}

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

Future<List<double>?> preprocessImage(File imageFile, List<int> inputShape) async {
  try {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) return null;

    int inputHeight = inputShape[1];
    int inputWidth = inputShape[2];
    img.Image resizedImage = img.copyResize(image, width: inputWidth, height: inputHeight);

    if (inputShape[3] == 1) {
      resizedImage = img.grayscale(resizedImage);
    }

    List<double> input = [];
    for (var pixel in resizedImage.getBytes(format: inputShape[3] == 1 ? img.Format.luminance : img.Format.rgb)) {
      input.add(pixel / 255.0);
    }

    return input;
  } catch (e) {
    print('Error during preprocessing: $e');
    return null;
  }
}

Future<String> classifyImage(File imageFile) async {
  try {
    var inputShape = interpreter.getInputTensor(0).shape;
    List<double>? input = await preprocessImage(imageFile, inputShape);
    if (input == null) {
      return 'Error processing image';
    }

    var inputTensor = input.reshape(inputShape);

    var outputShape = interpreter.getOutputTensor(0).shape;
    var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);

    interpreter.run(inputTensor, output);

    if (output[0][0] > output[0][1]) {
      return 'Healthy';
    } else {
      return 'Unhealthy';
    }
  } catch (e) {
    print('Error classifying image: $e');
    return 'Error during classification';
  }
}

class HomePage extends StatelessWidget {
  Future<void> navigateToResultPage(BuildContext context, String result) async {
    await Navigator.pushNamed(context, '/result', arguments: result);
  }

  @override
  Widget build(BuildContext context) {
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
                ElevatedButton(
                  onPressed: () async {
                    if (interpreter == null) {
                      print('Interpreter not initialized');
                      return;
                    }
                    File? imageFile = await pickImageFromSource(ImageSource.camera);
                    if (imageFile != null) {
                      String result = await classifyImage(imageFile);
                      navigateToResultPage(context, result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Capture Image',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (interpreter == null) {
                      print('Interpreter not initialized');
                      return;
                    }
                    File? imageFile = await pickImageFromSource(ImageSource.gallery);
                    if (imageFile != null) {
                      String result = await classifyImage(imageFile);
                      navigateToResultPage(context, result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Upload Image',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
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
