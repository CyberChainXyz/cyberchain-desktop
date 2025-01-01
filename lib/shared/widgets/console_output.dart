import 'package:flutter/material.dart';

class ConsoleOutput extends StatelessWidget {
  final String output;
  final bool isRunning;

  const ConsoleOutput({
    super.key,
    required this.output,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Console Output',
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRunning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                output,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
