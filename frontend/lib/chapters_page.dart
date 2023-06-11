import 'package:flutter/material.dart';
import 'main.dart';
import 'utilities.dart';
import 'memories_page.dart';

class ChaptersPage extends StatefulWidget {
  final String uuid;
  final String name;

  const ChaptersPage({Key? key, required this.uuid, required this.name})
      : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
      length: 2,
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
              Tab(child: Text('Emotions')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChaptersTab(widget.uuid, index: 0), // Form for "Chapter" tab
            ChaptersTab(widget.uuid, index: 1), // Form for "Emotions" tab
          ],
        ),
      ),
    ));
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

  void createChapter(String uuid) async {
    await supabase
        .from('Chapters')
        .insert({'scrapbook': uuid, 'name': controller.text});
    final bucketId = await supabase
        .from('Chapters')
        .select("bucket_id")
        .eq("scrapbook", uuid)
        .eq("name", controller.text)
        .single();
    await supabase.storage.createBucket(bucketId["bucket_id"]);
    if (context.mounted) Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final future = supabase
        .from("Chapters")
        .select<List<Map<String, dynamic>>>()
        .eq("scrapbook", widget.uuid);

    return Scaffold(
      floatingActionButton: widget.allowChapterCreation
          ? FloatingActionButton(
              onPressed: () async {
                final name = await openChapterCreation();
                if (name == null || name.isEmpty) return;

                setState(() {
                  chapters.add(name);
                });
              },
              child: const Icon(Icons.add))
          : Container(),
      body: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(10),
        child: widget.allowChapterCreation 
          ? GenericFutureListView(
            future: future,
            genericTileBuilder: (chapters) {
              return GenericTile(
                name: chapters["name"],
                tileIcon: const Icon(Icons.menu_book, size: 30),
                navigatesTo: MemoriesPage(chapters["bucket_id"]),
              );
            },
          ) 
          : EmotionsWidget(),
      ),
    );
  }
}

class EmotionsWidget extends StatelessWidget {
  EmotionsWidget({super.key,});

  final List<String> emotions = ["Happy", "Soothing", "Exciting", "Sad", "Distressing"];
  final List<Color> emotionColours = [
    Colors.yellow, 
    Colors.green, 
    Colors.purple, 
    Colors.blue, 
    Colors.red
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var i = 0; i < emotions.length; i++)
          GenericTile(
            name: emotions[i], 
            tileIcon: const Icon(null), 
            navigatesTo: const Placeholder(),
            colour: emotionColours[i],
          )
      ],
    );
  }
}
