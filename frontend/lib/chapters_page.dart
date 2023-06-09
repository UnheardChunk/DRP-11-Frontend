import 'package:flutter/material.dart';
import 'main.dart';
import 'utilities.dart';
import 'memories_page.dart';

class ChaptersPage extends StatefulWidget {

  final String uuid;
  final String name;

  const ChaptersPage({Key? key, required this.uuid, required this.name}) : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.name}\'s scrapbook'),
            centerTitle: true,
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(child: Text('Chapters')),
                // Tab(child: Text('Senses')),
              ],
            ),
          ),
          body:  TabBarView(
            children: [
              ChaptersTab(widget.uuid, index: 0), // Form for "Chapter" tab
              // ChaptersTab(uuid, index: 1), // Form for "Senses" tab
            ],
          ),
        ),
      )
    );
  }
}

class ChaptersTab extends StatefulWidget {

  late final bool allowChapterCreation;
  final String uuid;

  ChaptersTab(this.uuid, {super.key, required index}) {
    allowChapterCreation = index == 0;
  }

  @override
  State<ChaptersTab> createState() => _ChaptersTabState();
}

class _ChaptersTabState extends State<ChaptersTab> {

  List<String> chapters = [];

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String?> openChapterCreation() {
    // Clears the text in the controller
    controller.clear();

    return showDialog<String>(
    context: context, 
    builder: (context) => AlertDialog(
        title: const Text("Create Chapter"),
        content: TextField(
          onSubmitted: (_) => createChapter(widget.uuid),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter the name of this chapter",
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => createChapter(widget.uuid),
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  void createChapter(String uuid) async{
    await supabase
        .from('Chapters')
        .insert({'scrapbook': uuid, 'name': controller.text});
    if (context.mounted) Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final future = supabase.from("Chapters").select<List<Map<String, dynamic>>>().eq("scrapbook", widget.uuid);

    return Scaffold(
      floatingActionButton: widget.allowChapterCreation ? FloatingActionButton(
        onPressed: () async {
          final name = await openChapterCreation();
          if (name == null || name.isEmpty) return;

          setState(() {
            chapters.add(name);
          });
        },
        child: const Icon(Icons.add)
      ) : Container(),
      body: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final chapters = data[index];
                  return GenericTile(
                    name: chapters["name"],
                    tileIcon: const Icon(Icons.menu_book, size: 30),
                    navigatesTo: const MemoriesPage(),
                  );
                },
              )
            );
          },
        )
      ),
    );
  }

}