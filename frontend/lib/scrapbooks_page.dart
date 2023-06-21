import 'package:flutter/material.dart';
import 'chapters_page.dart';
import 'main.dart';
import 'utilities.dart';
import 'package:tuple/tuple.dart';

// Creates the scrapbook page
class ScrapbooksPage extends StatefulWidget {
  final Profile profile;
  const ScrapbooksPage(this.profile, {super.key});

  @override
  State<ScrapbooksPage> createState() => _ScrapbooksPageState();
}

// The state for the scrapbook page
class _ScrapbooksPageState extends State<ScrapbooksPage> {
  // List of all the scrapbooks the user has
  List<String> scrapbooks = [];
  final _data = supabase.from("Scrapbooks").stream(primaryKey: ["id"]);

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
    await supabase.from('Scrapbooks').insert({
      'name': controller.text,
      "owners": [supabase.auth.currentUser!.id]
    });
    if (context.mounted) Navigator.of(context).pop(controller.text);
  }

  void _showSingleSelect(String uuid, List<dynamic> contributors) async {
    List<Tuple2> items = [
      const Tuple2("Adam", "cb965659-dacc-4268-848d-056ac9181992"),
      const Tuple2(
          "Adam (after a year)", "4dfcf557-5b65-4fed-b86f-796edf311955"),
      const Tuple2("Julia", "5bd6ed3e-d1f2-435f-9191-670989d207e8"),
      const Tuple2("Justin", "505d1b6f-1e46-4f3d-814a-7cb65094a402"),
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleSelect(
          uuid,
          items: items,
          initialContributors: contributors.map((e) => e as String).toList(),
        );
      },
    );
  }

  // Builds the main screen for the scrapbook page
  @override
  Widget build(BuildContext context) {
    //final auth = authenticate(widget.profile);

    return WillPopScope(
        onWillPop: () async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Log out ?'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      logOut();
                      Navigator.of(context).pop(true);
                    },
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
          body: GenericContainer(
              child: /*FutureBuilder(
                  future: auth,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = supabase
                        .from("Scrapbooks")
                        .select<List<Map<String, dynamic>>>();
                    return */
                  GenericStreamListView(
            stream: _data,
            genericTileBuilder: (scrapbook) {
              return GestureDetector(
                child: GenericTile(
                    name: scrapbook["name"],
                    tileIcon: const Icon(Icons.menu_book, size: 30),
                    navigatesTo: ChaptersPage(
                      uuid: scrapbook["id"],
                      name: scrapbook["name"],
                      owner: scrapbook["owner"],
                    )),
                onLongPress: () {
                  if (scrapbook["owner"] == supabase.auth.currentUser!.id) {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => GenericModalBottomSheetChild(
                            heightScale: 0.1,
                            child: ListView(
                              children: [
                                ListTile(
                                    title: const Text("Change owner"),
                                    onTap: () => _showSingleSelect(
                                        scrapbook["id"],
                                        scrapbook["contributors"]))
                              ],
                            )));
                  }
                },
              );
            },
            noContentText: "You have no scrapbooks",
          )
              //})
              ),
        ));
  }

  Future<void> logOut() async {
    await supabase.auth.signOut();
  }
}

class SingleSelect extends StatefulWidget {
  final List<Tuple2> items;
  final String uuid;
  final List<String> initialContributors;

  const SingleSelect(this.uuid,
      {super.key, required this.items, required this.initialContributors});

  @override
  State<SingleSelect> createState() => _SingleSelectState();
}

class _SingleSelectState extends State<SingleSelect> {
  late String _selectedOwner;
  late final List<String> _contributors;

  @override
  void initState() {
    _selectedOwner = supabase.auth.currentUser!.id;
    _contributors = widget.initialContributors;

    super.initState();
  }

  // Triggered when cancel button is selected
  void _cancel() {
    Navigator.pop(context);
  }

  // Triggered when submit button is called
  void _submit() async {
    _contributors.add(supabase.auth.currentUser!.id);
    if (_contributors.contains(_selectedOwner)) {
      _contributors.remove(_selectedOwner);
    }
    await supabase
        .from("Scrapbooks")
        .update({"owner": _selectedOwner, "contributors": _contributors}).eq(
            "id", widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Owner'),
      content: SingleChildScrollView(
          child: ListBody(
        children: widget.items
            .map((item) => RadioListTile(
                groupValue: _selectedOwner,
                value: item.item2,
                title: Text(item.item1),
                onChanged: (value) => {
                      setState(() {
                        _selectedOwner = value;
                      })
                    }))
            .toList(),
      )),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () {
              _submit();
              Navigator.pop(context, _selectedOwner);
              Navigator.pop(context);
            },
            child: const Text('Submit')),
      ],
    );
  }
}
