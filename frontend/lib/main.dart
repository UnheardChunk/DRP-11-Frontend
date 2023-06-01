import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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

  // @override
  // void dispose() {
  //   for (var controller in controllers) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }

  void addForm() {
    if (controllers.length < 5) {
      setState(() {
        controllers.add(TextEditingController());
        isFormSubmitted.add(false);
      });
    }
  }

  void submitForm(int index) {
    setState(() {
      isFormSubmitted[index] = true;
    });
  }

  void navigateToAnotherPage(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnotherPage(name: name),
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
              onPressed: () => submitForm(index),
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

  const AnotherPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapbook'),
      ),
      body: Center(
        child: Text('Hello, $name'),
      ),
    );
  }
}
