import 'package:flutter/material.dart';
import 'main.dart';
import 'chapters_page.dart';

// Creates the scrapbook page
class ScrapbooksPage extends StatefulWidget {
  const ScrapbooksPage({super.key});

  @override
  State<ScrapbooksPage> createState() => _ScrapbooksPageState();
}

// The state for the scrapbook page
class _ScrapbooksPageState extends State<ScrapbooksPage> {

  // List of all the scrapbooks the user has
  List<String> scrapbooks = [];

  // Controller for scrapbook creation
  late TextEditingController controller;

  // Initialises the scrapbook creation controller
  @override
  void initState() {
    super.initState();
    
    controller = TextEditingController();
  }

  // Disposes the scrapbook creation controller
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Opens an AlertDialog for creating a new scrapbook
  Future<String?> openScrapbookCreation() {
    // Clears the text in the controller
    controller.clear();

    return showDialog<String>(
    context: context, 
    builder: (context) => AlertDialog(
        title: const Text("Create Scrapbook"),
        content: TextField(
          onSubmitted: (_) => createScrapbook,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter your scrapbook name",
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: createScrapbook, 
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  // Pops the AlertDialog for scrapbook creation when the submit button is pressed
  void createScrapbook() {
    Navigator.of(context).pop(controller.text);
  }

  // Builds the main screen for the scrapbook page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await openScrapbookCreation();
          if (name == null || name.isEmpty) return;
          
          setState(() async {
            await supabase.from('Scrapbooks').insert({'name': name,'data': ""});
            scrapbooks.add(name);
          });
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('My scrapbooks'),
        centerTitle: true,
        leading: BackButton(
          onPressed:() {},
        ),
      ),

      body: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            for (String scrapbook in scrapbooks)
              ScrapbookTile(name: scrapbook,),
          ]
        ),
      ),

    );
  }

  // void navigateToMediaPage() async {
  //   //navigates to new page
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const MediaPage(),
  //     ),
  //   );
  // }

  void navigateToMediaPage() async {
    //navigates to new page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
    );
  }
}

// Class defining a ListTile for a scrapbook
class ScrapbookTile extends StatelessWidget {

  // Name of the scrapbook
  final String name;

  const ScrapbookTile({super.key, required this.name});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.menu_book, size: 30,),
        iconColor: Colors.black,
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChaptersPage(name: name)
            ),
          )
        },
      ),
    );
  }

}
