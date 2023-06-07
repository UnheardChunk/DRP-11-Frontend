import 'package:flutter/material.dart';
import 'main.dart';
import 'chapters_page.dart';

class ScrapbooksPage extends StatefulWidget {
  const ScrapbooksPage({super.key});

  @override
  State<ScrapbooksPage> createState() => _ScrapbooksPageState();
}

class _ScrapbooksPageState extends State<ScrapbooksPage> {
  // static const maxNumScrapbooks = 5;

  //list of TextEditingController objects controls text input in each form
  List<TextEditingController> controllers = [];

  //tracks whether each form has been submitted or not
  List<bool> isFormSubmitted = [];
  List<bool> isFormEditable = [];


  //add initial form. ensures there is at least one form when the page is first loaded.
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
    //adds a new form to controllers list and sets corresponding isFormSubmitted bool to false.
    setState(() {
      controllers.add(TextEditingController());
      isFormSubmitted.add(false);
      isFormEditable.add(true);
    });
  }

  Future<void> submitForm(int index, String name) async {
    final nameController = controllers[index];

    if (nameController.text.isNotEmpty) {
      setState(() {
        isFormSubmitted[index] = true;
        isFormEditable[index] = false;
      });
    }

    final data = await supabase.from('Scapbooks').insert({'name': name,'data': ""});
    return data;

  }

  void navigateToScrapbookPage(String name) async {
    //navigates to new page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChaptersPage(name: name),
      ),
    );
  }

  //generates form widget
  //displays a TextFormField for form input, and corresponding 'Submit' or 'See scrapbook' button
  Widget buildForm(int index) {
    final nameController = controllers[index];
    final isSubmitted = isFormSubmitted[index];
    final isTextEntered = nameController.text.isNotEmpty;
    final isEditable = isFormEditable[index];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            onChanged: (value) {
              setState(() {
              });
            },
            enabled: isEditable,
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
              //can't submit unless text has been entered
              onPressed:
              isTextEntered ? () => submitForm(index, nameController.text) : null,
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
        title: const Text('My scrapbooks'),//\nYou have ${controllers.length} scrapbooks'),
        centerTitle: true,
        leading: BackButton(
          onPressed:() {},
        ),
      ),

      //ListView.builder creates a scrollable linear array of widgets
      body: ListView.builder(
        itemCount: controllers.length,
        itemBuilder: (context, index) {
          if (index == controllers.length - 1) {
            //creates new form
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
