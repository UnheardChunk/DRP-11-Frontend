
import 'package:flutter/material.dart';
import 'main.dart';


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
    final data = await supabase.from('Scapbooks').insert({'name': name,'data': ""});
    return data;

  }

  Future<Scaffold> navigateToScrapbookPage(String name) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrapbookPage(name: name),
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
              onPressed: () => navigateToScrapbookPage(nameController.text),
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
        title: const Text('MYSCRAPBOOKS'),
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

