// candidate_detail.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class CandidateDetailPage extends StatelessWidget {
  final DocumentSnapshot candidate;

  const CandidateDetailPage({
    Key? key,
    required this.candidate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = candidate['name'];
    final String imageUrl = candidate['imageUrl'];
    final String manifesto = candidate['manifesto'];

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(name),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ' Name: $name',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              const Text(
                'Manifesto:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                manifesto,
                maxLines: 500,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
