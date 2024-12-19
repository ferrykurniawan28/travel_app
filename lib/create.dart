import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'package:travel_app/models/places.dart';

class CreatePlaceScreen extends StatefulWidget {
  const CreatePlaceScreen({super.key});

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _placeName = '';
  String _description = '';
  File? _image;
  bool _isloading = false;

  final firebaseDB = FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // ask permission to access camera and gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Camera'),
                onTap: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _image = File(image.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Gallery'),
                onTap: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _image = File(image.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isloading = true;
      });
      String imagePath =
          '/places/${FirebaseAuth.instance.currentUser!.uid}/$_placeName.jpg';
      try {
        final response = await Supabase.instance.client.storage
            .from('places')
            .upload(imagePath, _image!,
                fileOptions: const FileOptions(
                  upsert: true,
                ));

        String imageUrl = Supabase.instance.client.storage
            .from('places')
            .getPublicUrl(imagePath);

        print("Image uploaded successfully");

        final newPlace = Places(
          title: _placeName,
          description: _description,
          imageUrl: imageUrl,
          uid: FirebaseAuth.instance.currentUser!.uid,
        );

        await firebaseDB.collection('places').add(newPlace.toMap());

        Navigator.pop(context);
      } catch (e) {
        print(e);
      }

      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Place Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the place name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _placeName = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  height: _image == null ? 200 : null,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Pick Image'),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Image.file(_image!),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                if (_isloading) const CircularProgressIndicator(),
                if (!_isloading)
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
