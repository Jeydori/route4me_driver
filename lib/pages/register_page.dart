import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:route4me_driver/components/button.dart';
import 'package:route4me_driver/components/text_field.dart';
import 'package:route4me_driver/components/circle_tile.dart';
import 'package:route4me_driver/global/global.dart';
import 'package:route4me_driver/pages/car_info_page.dart';
import 'package:route4me_driver/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // sign user up method
  void signUp() async {
    if (passwordController.text == confirmPasswordController.text) {
      // Use AuthService to register the user
      var authService = AuthService();
      var user = await authService.registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // User has been created and verification email sent
        await addUserDetails(
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          int.parse(ageController.text.trim()),
          emailController.text.trim(),
          user.uid,
        );

        // Show a dialog asking the user to verify their email
        showDialog(
          context: context,
          builder: (context) {
            _startEmailVerificationCheck();
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registration successful! Please verify your email and wait a moment.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Verification email sent")),
                      );
                    },
                    child: const Text("Resend Verification Email"),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Show an error message if registration failed
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                textAlign: TextAlign.center,
                'Failed to register. Please try again.',
              ),
            );
          },
        );
      }
    } else {
      // Show error if passwords do not match
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text(
              textAlign: TextAlign.center,
              'Passwords do not match!',
            ),
          );
        },
      );
    }
  }

  Future<void> addUserDetails(String firstName, String lastName, int age,
      String email, String uid) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("Drivers").child(uid);
    await userRef.set({
      'First Name': firstName,
      'Last Name': lastName,
      'Age': age,
      'Email': email,
      'Uid': uid,
    }).then((_) {
      print("User added with ID: $uid");
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = firebaseAuth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        _timer?.cancel();
        Navigator.of(context).pop(); // Close the dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const carInfoPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'lib/images/route4me logo.png',
                  height: 100,
                  width: 100,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Register below with your details!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
                // First name textfield
                const SizedBox(height: 1),
                textfield(
                  controller: firstNameController,
                  hintText: '   First Name',
                  obscureText: false,
                ),
                // Last name textfield
                const SizedBox(height: 1),
                textfield(
                  controller: lastNameController,
                  hintText: '   Last Name',
                  obscureText: false,
                ),
                // Age textfield
                const SizedBox(height: 1),
                textfield(
                  controller: ageController,
                  hintText: '   Age',
                  obscureText: false,
                ),
                // Email textfield
                const SizedBox(height: 1),
                textfield(
                  controller: emailController,
                  hintText: '   Email',
                  obscureText: false,
                ),
                // Password field
                const SizedBox(height: 1),
                textfield(
                  controller: passwordController,
                  hintText: '   Password',
                  obscureText: true,
                ),
                // Confirm password field
                const SizedBox(height: 1),
                textfield(
                  controller: confirmPasswordController,
                  hintText: '   Confirm Password',
                  obscureText: true,
                ),

                // Sign up button
                const SizedBox(height: 15),
                button(
                  text: "Sign Up",
                  onTap: signUp,
                ),
                // Divider
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Continue with',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/Google.png',
                    ),
                  ],
                ),

                const Divider(thickness: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
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
