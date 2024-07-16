import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:route4me_driver/components/button.dart';
import 'package:route4me_driver/components/text_field.dart';
import 'package:route4me_driver/global/global.dart';
import 'package:route4me_driver/pages/home_page.dart';

class carInfoPage extends StatefulWidget {
  const carInfoPage({super.key});

  @override
  State<carInfoPage> createState() => _carInfoPageState();
}

class _carInfoPageState extends State<carInfoPage> {
  final carPlateController = TextEditingController();
  List<String> carTypes = [
    'Jeepney (TPUJ)',
    'E-Jeepney Aircon (A-MPUJ)',
    'E-Jeepney Non-Aircon (Na-MPUJ)',
    'Bus Aircon (A-PUB)',
    'Bus Ordinary (O-PUB)'
  ];
  String? selectedCarType;
  File? _image;

  @override
  void dispose() {
    carPlateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final userId = currentUser.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('car_images')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Failed to upload image: $e");
      return null;
    }
  }

  void savePUVDetails() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .ref()
            .child('Drivers')
            .child(currentUser.uid);

        String? imageUrl;
        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        await userRef.update({
          'carPlate': carPlateController.text,
          'carType': selectedCarType,
          'carImage': imageUrl,
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.orange, width: 2),
              ),
              title: const Text(
                'Success',
                style: TextStyle(color: Colors.black),
              ),
              content: const Text(
                'PUV details added successfully!',
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Current user is null');
      }
    } catch (error) {
      print("Failed to save PUV details: $error");
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.orange, width: 2),
            ),
            title: const Text(
              'Error',
              style: TextStyle(color: Colors.black),
            ),
            content: const Text(
              'Failed to save PUV details. Please try again later.',
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                Icon(
                  Icons.bus_alert_outlined,
                  size: 100,
                  color: Colors.orange[600],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Add PUV Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                textfield(
                  controller: carPlateController,
                  hintText: '   Plate No.',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: '   Choose PUV Type',
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                      items: carTypes.map((car) {
                        return DropdownMenuItem(
                          value: car,
                          child: Text(
                            car,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCarType = newValue.toString();
                        });
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                _image != null
                    ? Image.file(_image!)
                    : const Text('No image selected.'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white, // Text color
                        side: const BorderSide(
                            color: Colors.orange), // Border color
                      ),
                      child: const Text('Upload Image'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _captureImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white, // Text color
                        side: const BorderSide(
                            color: Colors.orange), // Border color
                      ),
                      child: const Text('Capture Image'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(height: 15),
                button(
                  text: "Add Details",
                  onTap: savePUVDetails,
                ),
                const SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}
