import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:route4me_driver/pages/profile_page.dart';
import 'package:route4me_driver/services/acc_del.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _confirmLogout(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text("Are you sure you want to log out?"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.orange, width: 2),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false; // Handling the case where dialog is dismissed with no selection

    if (confirm) {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, right: 50, left: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/images/route4me logo.png',
                width: 250,
                height: 250,
              ),
              const Divider(
                color: Colors.black,
                thickness: 1.0,
              ),
              const SizedBox(height: 20),
              const Text(
                'General Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyPolicy(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "Privacy",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showSecurityInfo(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "Security",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showAboutUs(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "About Us",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28.0),
              const Text(
                'Account',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const ProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AccountManagement.showDeleteConfirmation(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _confirmLogout(context); // Use the confirm logout function
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPrivacyPolicy(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Privacy Policy',
          textAlign: TextAlign.center,
        ),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'We take your privacy seriously. This means we only collect personal information that is necessary to provide you with our service. You will always have choices about what information you share and how we use it.',
                textAlign: TextAlign.center,
              ),
              Text(
                'We will never sell your personal information to third parties, and we will take appropriate security measures to protect your data.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.orange),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

void _showAboutUs(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Determine the available screen height and width
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      return AlertDialog(
        title: const Text(
          'About Us',
          textAlign: TextAlign.center,
        ),
        content: Container(
          // Set a maximum width to ensure the dialog looks good on all devices
          width: screenWidth * 0.9,
          // Limit the height to prevent overflow on small devices
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use AspectRatio to maintain the image's aspect ratio
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'lib/images/route4me logo.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Our team of developers has poured their expertise into creating these options, allowing you to customize features and optimize your workflow. We\'re constantly working to improve Route4Me. If you have any suggestions, please don\'t hesitate to send us feedback through the app.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.orange),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void _showSecurityInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Security Information',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                'Your security is our top priority. We use industry-standard encryption to protect your data at rest and in transit. Our application ensures secure connections to prevent unauthorized access.',
                textAlign: TextAlign.center,
              ),
              Text(
                'For your safety, always keep your software updated and be cautious of unsolicited requests asking for your personal information.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.orange),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
