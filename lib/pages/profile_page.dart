import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:route4me_driver/global/global.dart';
import 'package:route4me_driver/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch current user's info when the profile page is initialized
    readCurrentOnlineUserInfo();
  }

  Future<void> readCurrentOnlineUserInfo() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .reference()
            .child('Users')
            .child(currentUser.uid);

        DataSnapshot snapshot = (await userRef.once()) as DataSnapshot;

        if (snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            userModelCurrentInfo = UserModel(
              firstName: data['First Name'] ?? '',
              lastName: data['Last Name'] ?? '',
              age: data['Age'] ?? 0,
              email: data['Email'] ?? '',
              uid: currentUser.uid,
            );
            // Set the initial values for all fields
            firstNameController.text = userModelCurrentInfo!.firstName;
            lastNameController.text = userModelCurrentInfo!.lastName;
            ageController.text = userModelCurrentInfo!.age.toString();
            emailController.text = userModelCurrentInfo!.email;
          });
          print('User info retrieved: $userModelCurrentInfo');
        } else {
          throw Exception('User document does not exist');
        }
      } else {
        throw Exception('Current user is null');
      }
    } catch (error) {
      print("Failed to get user info: $error");
      // Handle error
    }
  }

  Future<void> showUserNameDialogAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User Information'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement the logic to update user information in Firebase Realtime Database
                updateUserInfo();
                Navigator.pop(context);
              },
              child: const Text(
                'Ok',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserInfo() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseDatabase.instance
            .reference()
            .child('Users')
            .child(currentUser.uid);

        await userRef.update({
          'First Name': firstNameController.text,
          'Last Name': lastNameController.text,
          'Age': int.tryParse(ageController.text) ?? 0,
          'Email': emailController.text,
        });

        // Update local user model with the new information
        setState(() {
          userModelCurrentInfo!.firstName = firstNameController.text;
          userModelCurrentInfo!.lastName = lastNameController.text;
          userModelCurrentInfo!.age = int.tryParse(ageController.text) ?? 0;
          userModelCurrentInfo!.email = emailController.text;
        });

        print('User information updated successfully');
      } else {
        throw Exception('Current user is null');
      }
    } catch (error) {
      print("Failed to update user information: $error");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, size: 80),
                ),
                const SizedBox(height: 30),
                // Text form fields for user information
                TextFormField(
                  controller: firstNameController,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                TextFormField(
                  controller: lastNameController,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                TextFormField(
                  controller: ageController,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showUserNameDialogAlert(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.orange[600],
                  ),
                  child: const Text(
                    'Edit Information',
                    style: TextStyle(color: Colors.black),
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
