import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/views/auth/splash_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/home/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize(
  url: 'https://xdeljurhomgxtwrimtfy.supabase.co',
  anonKey: 'sb_publishable_OVZHSkL7t_IBm1d7uOJgzg_n3N7BkxR',
);
  runApp(
    // ChangeNotifierProvider makes AuthViewModel available to the whole tree
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on existing Supabase session
    final hasSession =
        Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      title: 'Student Assistant App',
      debugShowCheckedModeBanner: false,
      // initialRoute: hasSession ? '/home' : '/login',
      initialRoute: hasSession ? '/home' : '/',
      routes: {
        '/': (_) => const SplashView(),
        '/login': (_) => const LoginView(),
        '/register': (_) => const RegisterView(),
        '/home': (_) => const HomeView(),
        // '/admin': (_) => const AdminDashboardView(), // add later
      },
    );
  }
}