import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/public_profile_screen.dart';
import 'screens/locked_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyBioApp());
}

Locale localeForNationality(String? nationality) {
  return nationality == 'JP' ? const Locale('ja') : const Locale('ko');
}

class MyBioApp extends StatefulWidget {
  const MyBioApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    context.findAncestorStateOfType<_MyBioAppState>()?._setLocale(locale);
  }

  @override
  State<MyBioApp> createState() => _MyBioAppState();
}

class _MyBioAppState extends State<MyBioApp> {
  late Locale _locale = _detectInitialLocale();

  Locale _detectInitialLocale() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == deviceLocale.languageCode) return supported;
    }
    return const Locale('ko');
  }

  void _setLocale(Locale locale) {
    if (_locale == locale) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'murimuri.io',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
          return _AuthedRouter(user: snapshot.data!);
        }
        return const LoginScreen();
      },
    );
  }
}

class _AuthedRouter extends StatelessWidget {
  final User user;
  const _AuthedRouter({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.pastelPurple),
            ),
          );
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data?['isLocked'] == true) {
          return LockedAccountScreen(uid: user.uid);
        }
        final nationality = data?['nationality'] as String?;
        if (nationality != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MyBioApp.setLocale(context, localeForNationality(nationality));
          });
        }
        return const DashboardScreen();
      },
    );
  }
}
