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

// Function to preprocess image (resize and normalize)
Future<List<List<List<List<double>>>>> preprocessImage(File imageFile, List<int> inputShape) async {
  try {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) return [];

    // Resize the image to the input shape dimensions
    int inputHeight = inputShape[1];
    int inputWidth = inputShape[2];
    img.Image resizedImage = img.copyResize(image, width: inputWidth, height: inputHeight);

    // Normalize pixel values to [0, 1]
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

Future<String> classifyImage(File imageFile) async {
  try {
    // Get input shape of the model
    var inputShape = interpreter.getInputTensor(0).shape; // Example: [1, 180, 180, 3]

    // Preprocess image and reshape it to match input shape
    var input = await preprocessImage(imageFile, inputShape);
    if (input.isEmpty) return 'Error processing image';

    // Prepare the output tensor
    var outputShape = interpreter.getOutputTensor(0).shape; // Example: [1, 1]
    var output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    // Run inference
    interpreter.run(input, output);

    // Access the probability from the output
    double probability = output[0][0]; // Accessing the single value in the [1, 1] output

    // Interpret the result based on thresholding
    if (probability > 0.5) {
      print('Image classified as Unhealthy (Probability: ${probability.toStringAsFixed(2)})');
      return 'Unhealthy';
    } else {
      print('Image classified as Healthy (Probability: ${(1 - probability).toStringAsFixed(2)})');
      return 'Healthy';
    }
  } catch (e) {
    print('Error classifying image: $e');
    return 'Error during classification';
  }
}

class HomePage extends StatelessWidget {
  Future<void> navigateToResultPage(
      BuildContext context, String result, String imagePath) async {
    await Navigator.pushNamed(
      context,
      '/result',
      arguments: {'result': result, 'imagePath': imagePath},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      String result = await classifyImage(imageFile);
                      navigateToResultPage(context, result, imageFile.path);
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
                    File? imageFile = await pickImageFromSource(ImageSource.gallery);
                    if (imageFile != null) {
                      String result = await classifyImage(imageFile);
                      navigateToResultPage(context, result, imageFile.path);
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
