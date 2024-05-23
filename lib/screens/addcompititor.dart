import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class AddCompetitorPage extends StatefulWidget {
  static const String routeName = '/add_competitor';

  const AddCompetitorPage({super.key});

  @override
  State<AddCompetitorPage> createState() => _AddCompetitorPageState();
}

class _AddCompetitorPageState extends State<AddCompetitorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _image;
  bool _isUploading = false;
  late String uploadingText = '';

  Future<void> _addCompetitor(BuildContext context) async {
    if (_isUploading) {
      return;
    } else {
      setState(() {
        _isUploading = true;
        uploadingText = 'Uploading...';
      });

      if (_formKey.currentState!.validate()) {
        try {
          String imageUrl = '';
          if (_image != null) {
            try {
              // Upload image to Firebase Storage
              Reference storageRef =
                  FirebaseStorage.instance.ref().child('competitor_images').child('competitor_images ${DateTime.now()}');
              await storageRef.putFile(_image!);

              // Get the image URL
              await storageRef.getDownloadURL().then((value) {
                imageUrl = value;
              });
            } catch (e) {
              print('Failed to upload image: $e');
              // Handle error if upload fails
            }
          }

          await FirebaseFirestore.instance.collection('competitors').add({
            'name': _nameController.text,
            'manifesto': _descriptionController.text,
            'imageUrl': imageUrl, // If using Firebase Storage
            'votes': 0,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competitor added successfully!'),
            ),
          );
          _nameController.clear();
          _descriptionController.clear();
          setState(() {
            _image = null;
            uploadingText = '';
            _isUploading = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add competitor. Please try again.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Add Competitor'),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _getImage,
                  child: _image == null
                      ? Container(
                          color: Colors.grey.withOpacity(0.5),
                          height: 200,
                          child: const Center(
                            child: Icon(Icons.add_a_photo,
                                color: Colors.white, size: 50),
                          ),
                        )
                      : Image.file(_image!, height: 200, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Competitor Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    errorStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a competitor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Manifesto',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    errorStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed:(){ _addCompetitor(context);},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Add Competitor'),
                  ),
                ),
                const SizedBox(height: 15.0,),
                Center(
                  child: Text(
                    _isUploading ? uploadingText : '',
                    style: const TextStyle(color: Colors.white),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
