import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:route4me_driver/firebase_options.dart';
import 'package:route4me_driver/info%20handler/app_info.dart';
import 'package:route4me_driver/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const route4me_driver());
}

class route4me_driver extends StatelessWidget {
  const route4me_driver({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => appInfo(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Route4Me',
        home: SplashPage(),
      ),
    );
  }
}
