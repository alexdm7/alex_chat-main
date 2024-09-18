import 'package:alex_chat/screens/auth.dart';
import 'package:alex_chat/screens/chat.dart';
import 'package:alex_chat/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(

        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home:  StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx,snapchat){
            if(snapchat.connectionState==ConnectionState.waiting){
              return const SplashScreen();
            }
            if(snapchat.hasData){
              return const ChartScreen();
            }
            return const AuthScreen();
      }
      ),
    );
  }
}
