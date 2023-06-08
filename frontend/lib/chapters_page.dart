import 'package:flutter/material.dart';
import 'utilities.dart';
import 'memories_page.dart';

class ChaptersPage extends StatefulWidget {
  final String name;

  const ChaptersPage({Key? key, required this.name}) : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {

  ChaptersTab chaptersTab = ChaptersTab(index: 0);
  ChaptersTab emotionsTab = ChaptersTab(index: 1);

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
          body: TabBarView(
            children: [
              chaptersTab, // Form for "Chapter" tab
              // emotionsTab, // Form for "Senses" tab
            ],
          ),
        ),
      ),
    );
  }
}

class ChaptersTab extends StatefulWidget {

  late final bool allowChapterCreation;

  ChaptersTab({super.key, required index}) {
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
          onSubmitted: (_) => createChapter,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter the name of this chapter",
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: createChapter, 
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  void createChapter() {
    Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          children: [
            for (String chapter in chapters)
              GenericTile(
                name: chapter, 
                tileIcon: const Icon(Icons.bookmark, size: 30,), 
                navigatesTo: const MemoriesPage(),
              ),
          ]
        ),
      ),
    );
  }

}