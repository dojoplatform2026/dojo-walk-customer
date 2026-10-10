
import 'package:flutter/material.dart';

import '../features/splash/screens/splash_screen.dart';

class DojoWalkApp extends StatelessWidget {
  const DojoWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOJO WALK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7900),
          primary: const Color(0xFFFF7900),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
