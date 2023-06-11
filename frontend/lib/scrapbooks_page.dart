import 'package:flutter/material.dart';
import 'chapters_page.dart';
import 'main.dart';
import 'utilities.dart';


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
  void createScrapbook() async {
    await supabase
        .from('Scrapbooks')
        .insert({'name': controller.text});
    if (context.mounted) Navigator.of(context).pop(controller.text);

  }

  // Builds the main screen for the scrapbook page
  @override
  Widget build(BuildContext context) {
    final data = supabase.from("Scrapbooks").select<List<Map<String, dynamic>>>();
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Confirm that you want to Exit'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes')),
            ],
          ),
        );
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final name = await openScrapbookCreation();
            if (name == null || name.isEmpty) return;

            setState(() {
              scrapbooks.add(name);
            });
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('My scrapbooks'),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.grey[300],
          padding: const EdgeInsets.all(10),
          child: GenericFutureListView(
            future: data,
            genericTileBuilder: (scrapbook) {
              return GenericTile(
                name: scrapbook["name"],
                tileIcon: const Icon(Icons.menu_book, size: 30),
                navigatesTo: ChaptersPage(uuid: scrapbook["id"], name: scrapbook["name"]),
              );
            },
          )
        ),
      )
    );
  }
}
