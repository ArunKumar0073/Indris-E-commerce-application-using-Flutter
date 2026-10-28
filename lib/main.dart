import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'theme/app_theme.dart';
import 'pages/main_shell.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IndrisApp());
}

class IndrisApp extends StatelessWidget {
  const IndrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indris',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Named routes so any page can navigate by name
      initialRoute: '/',
      routes: {
        '/': (_) => const _AuthGate(),
        '/home': (_) => const MainShell(),
        '/login': (_) => const LoginPage(),
      },
    );
  }
}

/// Checks the current Firebase auth state ONCE at startup:
///   • Already signed in  → go straight to MainShell
///   • Not signed in      → go to LoginPage
///
/// After this initial check, login/logout pages handle their own
/// navigation explicitly — we do NOT rely on stream rebuilds for routing.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still resolving
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }

        // Signed in → push MainShell, remove AuthGate from stack
        if (snapshot.hasData && snapshot.data != null) {
          // Use addPostFrameCallback so we navigate after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          // Show loader while the navigation happens
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }

        // Not signed in
        return const LoginPage();
      },
    );
  }
}
