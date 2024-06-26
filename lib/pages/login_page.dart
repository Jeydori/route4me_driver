import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:route4me_driver/components/button.dart';
import 'package:route4me_driver/components/text_field.dart';
import 'package:route4me_driver/components/circle_tile.dart';
import 'package:route4me_driver/pages/forgot_page.dart';
import 'package:route4me_driver/pages/home_page.dart';
import 'package:route4me_driver/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void logIn() async {
    showLoadingDialog();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Optionally fetch additional user details here if necessary

      dismissLoadingDialog(); // Ensure dialog is dismissed before navigating

      // Navigate to HomePage or similar
      navigateToHome();
    } on FirebaseAuthException catch (e) {
      dismissLoadingDialog();
      showErrorDialog(e.message ?? "An unknown error occurred.");
    } catch (e) {
      dismissLoadingDialog();
      showErrorDialog('An unexpected error occurred: ${e.toString()}');
    }
  }

  void showLoadingDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void dismissLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Dismiss the error dialog
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 50),
            Image.asset(
              'lib/images/route4me logo.png',
              height: 260,
              width: 300,
            ),

            //emailfield
            const SizedBox(height: 1),
            textfield(
              controller: emailController,
              hintText: '   Email',
              obscureText: false,
            ),
            //passwordfield
            const SizedBox(height: 1),
            textfield(
              controller: passwordController,
              hintText: '   Password',
              obscureText: true,
            ),
            //forgotpassword
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ForgotPasswordPage();
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //signIn button
            const SizedBox(height: 15),
            button(
              text: "Log In",
              onTap: logIn,
            ),
            //divider
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
                    imagePath: 'lib/images/Google.png'),
                /*SizedBox(width: 0),
                CircleTile(onTap: () {}, imagePath: 'lib/images/Facebook.png'),*/
              ],
            ),

            const Divider(thickness: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No account?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      )),
    );
  }
}
