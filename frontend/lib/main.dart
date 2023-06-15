import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scrapbooks_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://cjcjooldtthzjlnpknaf.supabase.co',
      // anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqY2pvb2xkdHRoempsbnBrbmFmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NTU1ODc1OSwiZXhwIjoyMDAxMTM0NzU5fQ.cXwzHzFAIizOyQ26MZhZZdCHUQRybqBALGQpLKF3mXw'

      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqY2pvb2xkdHRoempsbnBrbmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODU1NTg3NTksImV4cCI6MjAwMTEzNDc1OX0.rCbTxIImYWlOyVh67BNlYF-5i9GJD6glXSVYn2M9F1c');
  runApp(const MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      //home: ScrapbooksPage(),
    );
  }
}

class Profile {
  final String name;
  final String image;
  final String email;
  final String password;

  Profile(
      {required this.name,
      required this.image,
      required this.email,
      required this.password});
}

class LoginScreen extends StatelessWidget {
  List<Profile> profiles = [
    Profile(
        name: 'Shruti',
        image: 'assets/profile.png',
        email: 'sp1521@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Huzaifah',
        image: 'assets/profile.png',
        email: 'hf521@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Krish',
        image: 'assets/profile.png',
        email: 'krm221@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Gabriel',
        image: 'assets/profile.png',
        email: 'gd221@ic.ac.uk',
        password: 'Pass123'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Select a profile')),
        body: ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20.0),
                leading: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage(profile.image)),
                  ),
                  child: Image.asset(profile.image),
                ),
                title: Text(
                  profile.name,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final AuthResponse res =
                      await supabase.auth.signInWithPassword(
                    email: profile.email,
                    password: profile.password,
                  );
                  final Session? session = res.session;
                  final User? user = res.user;
                  print('Selected profile: ${profile.name}');
                },
              ),
            );
          },
        ));
  }
}
