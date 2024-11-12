import 'package:carsnap/history.dart';
import 'package:carsnap/view_car_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'login.page.dart';
import 'register.page.dart';
import 'home.page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  Gemini.init(apiKey: 'AIzaSyAbowPdk6QfiPWCPmrTlJkcxTiEZGkHUNw');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => HomePage(),
          '/view': (context) => ViewCarPage(),
          '/history': (context) => HistoryPage(),
        },
      ),
    );
  }
}
