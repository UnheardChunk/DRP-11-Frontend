import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'name_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cjcjooldtthzjlnpknaf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqY2pvb2xkdHRoempsbnBrbmFmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NTU1ODc1OSwiZXhwIjoyMDAxMTM0NzU5fQ.cXwzHzFAIizOyQ26MZhZZdCHUQRybqBALGQpLKF3mXw',
  );
  runApp(const MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NameFormPage(),
    );
  }
}
