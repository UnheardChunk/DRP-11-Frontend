import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scrapbooks_page.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://cjcjooldtthzjlnpknaf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqY2pvb2xkdHRoempsbnBrbmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODU1NTg3NTksImV4cCI6MjAwMTEzNDc1OX0.rCbTxIImYWlOyVh67BNlYF-5i9GJD6glXSVYn2M9F1c');
  await Supabase.instance.client.auth.signInWithPassword(
    email: 'hf521@ic.ac.uk',
    password: 'Pass123',
  );
  runApp(const MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: Colors.pinkAccent[100]),
          cardColor: Colors.blueGrey,
          textTheme: GoogleFonts.interTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.pinkAccent[100]))),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.pinkAccent[100],
              hoverColor: Colors.pinkAccent)),
      home: LoginScreen(),
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
  final List<Profile> profiles = [
    Profile(
        name: 'Adam',
        image: 'assets/profile.png',
        email: 'sp1521@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Adam (after a year)',
        image: 'assets/profile.png',
        email: 'hf521@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Julia',
        image: 'assets/profile.png',
        email: 'krm221@ic.ac.uk',
        password: 'Pass123'),
    Profile(
        name: 'Justin',
        image: 'assets/profile.png',
        email: 'gd221@ic.ac.uk',
        password: 'Pass123'),
  ];

  LoginScreen({super.key});

  authenticate(Profile profile) async {
    await supabase.auth.signInWithPassword(
      email: profile.email,
      password: profile.password,
    );
  }

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
                  await authenticate(profile);
                  if (context.mounted) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ScrapbooksPage(profile)));
                  }
                },
              ),
            );
          },
        ));
  }
}
