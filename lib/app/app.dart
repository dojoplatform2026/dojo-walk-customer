import 'package:flutter/material.dart';

import 'theme.dart';
import '../screens/splash/splash_screen.dart';

class DojoWalkApp extends StatelessWidget {
  const DojoWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOJO WALK',
      debugShowCheckedModeBanner: false,
      theme: DojoWalkTheme.light(),
      home: const SplashScreen(),
    );
  }
}
