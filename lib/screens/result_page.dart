import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String result = ModalRoute.of(context)!.settings.arguments as String;

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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 5),
                  ),
                  child: Icon(
                    resultIcon,
                    size: 150,
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
                // Row to display the buttons side by side
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
                    const SizedBox(width: 20), // Space between buttons
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
