import 'package:broker_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: 'https://nthzmopgwaqfwcrhfgff.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHptb3Bnd2FxZndjcmhmZ2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMjg2OTcsImV4cCI6MjA3MjcwNDY5N30.OvgYUrUl0dR5ZBOBzavOioMivt0iXXe0KpcZ7by-2pk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const SplashScreen());
  }
}
