import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> carTypes = ['Jeepney', 'E-Jeepney', 'Bus'];
  String? selectedCarType;

  //final formKey = GlobalKey<FormState>();

  void savePUVDetails() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseFirestore.instance
            .collection('Drivers')
            .doc(currentUser.uid);

        await userRef.update({
          'carPlate': carPlateController.text,
          'carType': selectedCarType,
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('PUV details added successfully!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Text('OK'),
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
            title: Text('Error'),
            content:
                Text('Failed to save PUV details. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
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
          padding: EdgeInsets.all(10),
          children: [
            Column(
              children: [
                SizedBox(
                  height: 60,
                ),
                Icon(
                  Icons.bus_alert_outlined,
                  size: 100,
                  color: Colors.orange[600],
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Add PUV Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                textfield(
                  controller: carPlateController,
                  hintText: '   Plate No.',
                  obscureText: false,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: '   Choose PUV Type',
                        //prefixIcon: Icon(Icons.car_crash_outlined),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                      items: carTypes.map((car) {
                        return DropdownMenuItem(
                          child: Text(
                            car,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          value: car,
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCarType = newValue.toString();
                        });
                      }),
                ),
                SizedBox(
                  height: 20,
                ),

                //signUp button
                const SizedBox(height: 15),
                button(
                  text: "Add Details",
                  onTap: savePUVDetails,
                ),
                //divider
                const SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}
