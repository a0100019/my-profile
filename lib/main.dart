import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/public_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyBioApp());
}

class MyBioApp extends StatelessWidget {
  const MyBioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mybio.kr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: AppColors.background,
          primary: AppColors.pastelPurple,
          secondary: AppColors.pastelPink,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'u') {
          return MaterialPageRoute(
            builder: (_) => PublicProfileScreen(tag: uri.pathSegments[1]),
          );
        }
        return MaterialPageRoute(builder: (_) => const AuthGate());
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.pastelPurple),
            ),
          );
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
