import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tuple/tuple.dart';
import 'main.dart';
import 'utilities.dart';
import 'memories_page.dart';
import 'profile_page.dart';

class MultiSelect extends StatefulWidget {
  final List<Tuple2> items;
  final List<String> initialSelectedUsers;
  final String uuid;
  final String owner;

  const MultiSelect(this.uuid, this.initialSelectedUsers, this.owner,
      {super.key, required this.items});

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  late final List<String> _selectedUsers;

  @override
  void initState() {
    _selectedUsers = widget.initialSelectedUsers;
    super.initState();
  }

  // Triggered when a checkbox is checked / unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedUsers.add(itemValue);
      } else {
        _selectedUsers.remove(itemValue);
      }
    });
  }

  // Triggered when cancel button is selected
  void _cancel() {
    Navigator.pop(context);
  }

  // Triggered when submit button is called
  void _submit() async {
    await supabase
        .from("Scrapbooks")
        .update({"contributors": _selectedUsers}).eq("id", widget.uuid);
    print(_selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contributors'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .where((element) => element.item2 != widget.owner)
              .map((item) => CheckboxListTile(
                    value: _selectedUsers.contains(item.item2),
                    title: Text(item.item1),
                    onChanged: (isChecked) =>
                        _itemChange(item.item2, isChecked!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () {
              _submit();
              Navigator.pop(context, _selectedUsers);
            },
            child: const Text('Submit')),
      ],
    );
  }
}

class ChaptersPage extends StatefulWidget {
  final String uuid;
  final String name;
  final String owner;

  const ChaptersPage(
      {Key? key, required this.uuid, required this.name, required this.owner})
      : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  List<String> _selectedUsers = [];
  late bool isOwner;

  @override
  void initState() {
    populateInitUsers();
    super.initState();
    isOwner = supabase.auth.currentUser!.id == widget.owner;
  }

  populateInitUsers() async {
    final ret = await supabase
        .from("Scrapbooks")
        .select("contributors")
        .eq("id", widget.uuid)
        .single();
    _selectedUsers = ((ret["contributors"]) as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }

  void _showMultiSelect() async {
    List<Tuple2> items = [
      const Tuple2("Shruti", "cb965659-dacc-4268-848d-056ac9181992"),
      const Tuple2("Huzaifah", "4dfcf557-5b65-4fed-b86f-796edf311955"),
      const Tuple2("Krish", "5bd6ed3e-d1f2-435f-9191-670989d207e8"),
      const Tuple2("Gabriel", "505d1b6f-1e46-4f3d-814a-7cb65094a402"),
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          widget.uuid,
          _selectedUsers,
          widget.owner,
          items: items,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedUsers = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = isOwner
        ? [
            IconButton(
                onPressed: () {
                  _showMultiSelect();
                },
                icon: const Icon(
                  Icons.person_add,
                  size: 35,
                ))
          ]
        : [];
    final List<Widget> tabs = isOwner
        ? [
            const Tab(child: Text('Chapters')),
            const Tab(child: Text('Emotions')),
            const Tab(child: Text('Profile')),
          ]
        : [const Tab(child: Text('Chapters'))];
    final List<Widget> chapterTabs = isOwner
        ? [
            ChaptersTab(widget.uuid, widget.owner,
                index: 0), // Form for "Chapter" tab
            ChaptersTab(widget.uuid, widget.owner,
                index: 1), // Form for "Emotions" tab
            ChaptersTab(widget.uuid, widget.owner,
                index: 2), // Form for "Profile" tab
          ]
        : [ChaptersTab(widget.uuid, widget.owner, index: 0)];

    return Scaffold(
        body: DefaultTabController(
      length: isOwner ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.name}\'s scrapbook'),
          centerTitle: true,
          actions: actions,
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: chapterTabs,
        ),
      ),
    ));
  }
}

class ChaptersTab extends StatefulWidget {
  late final bool allowChapterCreation;
  late final bool isProfileTab;
  final String uuid;
  final String owner;

  ChaptersTab(this.uuid, this.owner, {super.key, required index}) {
    allowChapterCreation = index == 0;
    isProfileTab = index == 2;
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
      body: GenericContainer(
        child: widget.allowChapterCreation
            ? GenericFutureListView(
                future: future,
                genericTileBuilder: (chapter) {
                  return GenericTile(
                    name: chapter["name"],
                    tileIcon: const Icon(Icons.bookmark_outline, size: 30),
                    navigatesTo: MemoriesPage(
                      [chapter["bucket_id"]],
                      MemoryOrganisationType.chapters,
                      widget.owner,
                      name: chapter["name"],
                    ),
                  );
                },
              )
            : widget.isProfileTab
                ? ProfileWidget(uuid: widget.uuid)
                : EmotionsWidget(
                    allChapters: future,
                    owner: widget.owner,
                  ),
      ),
    );
  }
}

class EmotionsWidget extends StatelessWidget {
  final PostgrestFilterBuilder<List<Map<String, dynamic>>> allChapters;
  final String owner;

  EmotionsWidget({super.key, required this.allChapters, required this.owner});

  final List<String> emotions = [
    "Happy",
    "Soothing",
    "Exciting",
    "Sad",
    "Distressing"
  ];
  final List<Color> emotionColours = [
    Colors.yellow,
    Colors.green,
    Colors.purple,
    Colors.blue,
    Colors.red
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: allChapters,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<String> bucketIds = [];
          for (Map<String, dynamic> chapter in snapshot.data!) {
            bucketIds.add(chapter["bucket_id"]);
          }
          return ListView(
            children: [
              for (var i = 0; i < emotions.length - 1; i++)
                GenericTile(
                  name: emotions[i],
                  tileIcon: const Icon(null),
                  navigatesTo: MemoriesPage(
                    bucketIds,
                    MemoryOrganisationType.emotions,
                    owner,
                    emotion: emotions[i],
                    name: emotions[i],
                  ),
                  colour: emotionColours[i],
                ),
              // Tile for Distressing
              GestureDetector(
                onTap: () => _openDistressingEmotion(context, bucketIds),
                child: Card(
                  color: emotionColours[4],
                  child: ListTile(
                    title: Text(emotions[4]),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(null),
                  ),
                ),
              )
            ],
          );
        });
  }

  _openDistressingEmotion(BuildContext context, List<String> bucketIds) {
    Widget cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('Cancel'),
    );

    Widget continueButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MemoriesPage(
                  bucketIds,
                  MemoryOrganisationType.emotions,
                  emotion: emotions[4],
                  name: emotions[4],
                )));
      },
      child: const Text('Continue'),
    );

    AlertDialog alert = AlertDialog(
      title: const Text('See distressing memories?'),
      content: const Text(
          'The contents of this page may be sensitive. Are you sure you want to continue ?'),
      actions: [cancelButton, continueButton],
    );

    Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    });
  }
}

enum MemoryOrganisationType {
  emotions,
  chapters;
}
