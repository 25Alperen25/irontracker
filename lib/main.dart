import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:logger/logger.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'daily_progress_screen.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

if(kIsWeb){

  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyDzOGJx-YK65K4YUSaraVpfsFqfvuv4wcQ", appId: "1:523483187443:web:7ca0287f3c19618a194f86", messagingSenderId: "523483187443", projectId: "ema-iron-tracker", ),
  );
}else{

  await Firebase.initializeApp();
}
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Tracker',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/daily_progress') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DailyProgressScreen(
                day: args['day'],
                exercises: args['exercises'],
                addExercise: args['addExercise'],
                deleteExercise: args['deleteExercise'],
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}
