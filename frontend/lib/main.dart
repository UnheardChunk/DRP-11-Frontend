import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NameFormPage(),
    );
  }
}

class NameFormPage extends StatefulWidget {
  @override
  _NameFormPageState createState() => _NameFormPageState();
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
            decoration: InputDecoration(
              labelText: 'Enter name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          if (isSubmitted)
            ElevatedButton(
              onPressed: () => navigateToAnotherPage(nameController.text),
              child: Text('See scrapbook'),
            )
          else
            ElevatedButton(
              onPressed: () => submitForm(index),
              child: Text('Submit'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My scrapbooks'),
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
                  child: Icon(Icons.add),
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
        title: Text('Scrapbook'),
      ),
      body: Center(
        child: Text('Hello, $name'),
      ),
    );
  }
}
