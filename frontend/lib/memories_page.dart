import 'dart:typed_data';
import 'package:memories_scrapbook/utilities.dart';
import 'package:tuple/tuple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MemoriesPage extends StatefulWidget {
  final String bucketId;

  const MemoriesPage(this.bucketId, {super.key});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Tuple2<Future<Uint8List>, Map<String, dynamic>>> images = [];

  final ImagePicker picker = ImagePicker();
  late TextEditingController captionController;
  late TextEditingController responseController;
  late List<String> emotionsList;

  @override
  void initState() {
    super.initState();
    captionController = TextEditingController();
    responseController = TextEditingController();
    initialise();
  }

  initialise() async {
    final paths = await supabase.storage.from(widget.bucketId).list();
    final List<Map<String, dynamic>> emotions = await supabase.from("Emotions").select();
    emotionsList = (emotions.map((e) => e["emotion"] as String)).toList();

    for (FileObject path in paths) {
      final metadata = await supabase.from("Files")
                                    .select()
                                    .eq("bucket_id", widget.bucketId)
                                    .eq("name", path.name)
                                    .single();
      setState(() {
        images.add(Tuple2(supabase.storage.from(widget.bucketId).download(path.name), metadata));
      });
    }
  }

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    await displayBox(img);
  }

  uploadImage(XFile? img, String caption, String bucketId) async {
    await supabase.storage.from(widget.bucketId).upload(img!.name, File(img.path));
    await supabase.from("Files").insert({"bucket_id": bucketId, "name": img.name, "caption": caption});
    setState(() {
      images.add(Tuple2(img.readAsBytes(), <String, dynamic>{"caption": caption, "name": img.name, "emotion": "No Emotion", "response": null}));
    });
    if (context.mounted) Navigator.of(context).pop(captionController.text);

  }

  Future displayBox(XFile? img) {
    captionController.clear();

    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
      title: const Text("Add caption"),
      content:
        TextField(
        onSubmitted: (_) => uploadImage(img, captionController.text, widget.bucketId),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Enter a caption",
        ),
        controller: captionController,
      ),
      actions: [
        TextButton(
          onPressed: () => uploadImage(img, captionController.text, widget.bucketId),
          child: const Text("Submit"),
        )
      ],
        ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    responseController.dispose();
    super.dispose();
  }

  //show popup dialog
  void mediaAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Please choose media to select'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
              children: [
                  ElevatedButton(onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.gallery);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.image),
                      Text('From Gallery'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.camera);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.camera),
                      Text('From Camera'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Tuple2<String, String>?> openResponseCreation(Map metadata) {
    String dropdownValue = metadata["emotion"];
    responseController.text = metadata["response"] ?? "";

    return showDialog<Tuple2<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          titlePadding: const EdgeInsets.symmetric(horizontal: 15),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add response'),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? emotion) async {
                  setState(() {
                    dropdownValue = emotion!;
                  });
                },
                items: emotionsList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          content: TextField(
            onSubmitted: (_) => createResponse(dropdownValue, metadata["name"]),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter a response to this memory"
            ),
            controller: responseController,
          ),
          actions: [
            TextButton(
              onPressed: () => createResponse(dropdownValue, metadata["name"]),
              child: const Text("Submit"),
            ),
          ],
        )
      )
    );
  }

  void createResponse(String emotion, String path) async {
    print(path);
    await supabase.from("Files").update({"response": responseController.text, "emotion": emotion}).eq("bucket_id", widget.bucketId ).eq("name", path);
    if (context.mounted) Navigator.of(context).pop(Tuple2(responseController.text, emotion));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed:
          mediaAlert,

        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: GenericContainer(
        child: images.isNotEmpty
          ? SingleChildScrollView(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: images.map((image) {
                return FutureBuilder(
                  future: image.item1,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final img = snapshot.data!;
                    return Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                img,
                                fit: BoxFit.fitWidth,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final response = await openResponseCreation(image.item2);
                                  if (response == null) return;

                                  setState(() {
                                    image.item2["response"] = response.item1;
                                    image.item2["emotion"] = response.item2;
                                  });
                                },
                                child: const Icon(Icons.edit_note, size: 30,)  
                              ),
                            ),
                          ]
                        ),
                        Text(image.item2["caption"]),
                        const SizedBox(height: 25,),
                      ]
                    );
                  }
                );
              }).toList(),
            ),
          )
          : Container(),
      ),
    );
  }

}
