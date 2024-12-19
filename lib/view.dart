import 'package:flutter/material.dart';

class ViewPlace extends StatelessWidget {
  final String placeName;
  final String description;
  final String imageUrl;
  const ViewPlace(
      {super.key,
      required this.placeName,
      required this.description,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Place'),
      ),
      body: ListView(
        children: [
          Image.network(imageUrl),
          const SizedBox(height: 10),
          Center(
            child: Text(
              placeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
