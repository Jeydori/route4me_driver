import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    carPlateController.dispose();
    super.dispose();
  }

  void savePUVDetails() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .ref()
            .child('Drivers')
            .child(currentUser.uid);

        await userRef.update({
          'carPlate': carPlateController.text,
          'carType': selectedCarType,
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('PUV details added successfully!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text('OK'),
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
            title: const Text('Error'),
            content: const Text(
                'Failed to save PUV details. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                            style: TextStyle(color: Colors.grey[600]),
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
