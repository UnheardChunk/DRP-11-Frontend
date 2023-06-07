import 'package:flutter/material.dart';

class ScrapbookForm extends StatefulWidget {
  const ScrapbookForm({super.key});

  @override
  _ScrapbookFormState createState() => _ScrapbookFormState();
}

class _ScrapbookFormState extends State<ScrapbookForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> formFields = [''];

  void addFormField() {
    setState(() {
      formFields.add('');
    });
  }

  void removeFormField(int index) {
    setState(() {
      formFields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: formFields.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Add category',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Handle saving the form field value
                    },
                  ),
                  // trailing: IconButton(
                  //   icon: Icon(Icons.remove),
                  //   onPressed: () => removeFormField(index),
                  // ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addFormField,
          ),
        ],
      ),
    );
  }
}
