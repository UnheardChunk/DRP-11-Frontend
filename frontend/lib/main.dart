// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class NameFormPage extends StatefulWidget {
  const NameFormPage({super.key});

  @override
  State<NameFormPage> createState() => _NameFormPageState();
}

class _NameFormPageState extends State<NameFormPage> {
  List<TextEditingController> controllers = [];
  List<bool> isFormSubmitted = [];

  @override
  void initState() {
    super.initState();
    addForm();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addForm() {
    if (controllers.length < 5) {
      setState(() {
        controllers.add(TextEditingController());
        isFormSubmitted.add(false);
      });
    }
  }

  Future<void> submitForm(int index, String name) async {
    setState(() {
      isFormSubmitted[index] = true;
    });
    //final data = await supabase.from('Scapbooks').insert({'name': name,'data': {}});

  }

  Future<Scaffold> navigateToAnotherPage(String name) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnotherPage(name: name),
      ),
    );

    final data = await supabase
        .from('Scapbooks')
        .select('name, data').single();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapbook'),
      ),

      body: Center(
        child: Text(data),
      ),
    );
  }

  Widget buildForm(int index) {
    final nameController = controllers[index];
    final isSubmitted = isFormSubmitted[index];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            onChanged: (value) {
              // You can perform any required logic here
            },
            decoration: const InputDecoration(
              labelText: 'Enter name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (isSubmitted)
            ElevatedButton(
              onPressed: () => navigateToAnotherPage(nameController.text),
              child: const Text('See scrapbook'),
            )
          else
            ElevatedButton(
              onPressed: () => submitForm(index, nameController.text),
              child: const Text('Submit'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My scrapbooks'),
      ),
      body: ListView.builder(
        itemCount: controllers.length,
        itemBuilder: (context, index) {
          if (index == controllers.length - 1) {
            return Column(
              children: [
                buildForm(index),
                FloatingActionButton(
                  onPressed: addForm,
                  child: const Icon(Icons.add),
                ),
              ],
            );
          } else {
            return buildForm(index);
          }
        },
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  final String name;

  getJSON() async {
    final data = await supabase
        .from('Scapbooks')
        .select('name, data').eq('name', name).single();
    return data.toString();
  }
  const AnotherPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapbook'),
      ),

      body: const Center(

        child: Text(''),
      ),
    );
  }
}
