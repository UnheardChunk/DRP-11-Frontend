import 'dart:typed_data';
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
  State<MemoriesPage> createState() => _MemoriesPageState(bucketId);
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Tuple2<Future<Uint8List>, String>> images = [];

  final ImagePicker picker = ImagePicker();
  final String bucketId;
  late TextEditingController controller;

  _MemoriesPageState(this.bucketId);

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    initialise();
  }

  initialise() async {
    final paths = await supabase.storage.from(widget.bucketId).list();
    for (FileObject path in paths) {
      final caption = await supabase.from("Files").select("caption").eq("bucket_id", bucketId).eq("name", path.name).single();
      setState(() {
        images.add(Tuple2(supabase.storage.from(widget.bucketId).download(path.name), caption["caption"]));
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
      images.add(Tuple2(img.readAsBytes(), caption));
    });
    if (context.mounted) Navigator.of(context).pop(controller.text);

  }

  Future displayBox(XFile? img) {
    controller.clear();

    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
      title: const Text("Add caption"),
      content:
        TextField(
        onSubmitted: (_) => uploadImage(img, controller.text, bucketId),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Enter a caption",
        ),
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () => uploadImage(img, controller.text, bucketId),
          child: const Text("Submit"),
        )
      ],
        ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
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


  @override
  Widget build(BuildContext context) {
    String enteredText = ''; // Variable to store the entered text
    List<String> emotionsList = ['Happy', 'Soothing', 'Exciting', 'Sad', 'Distressing'];
    String dropdownValue = emotionsList.first;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (images.isNotEmpty)
                Column(
                  children: images.map((image) {
                    return FutureBuilder(
                      future: image.item1,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final img = snapshot.data!;
                        return Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 5, right: 0, bottom: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: const Alignment(1.0, -1.0),
                        children: [Image.memory(
                                  img,
                                  fit: BoxFit.fitWidth,
                                  width: MediaQuery.of(context).size.width,
                                ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Add an emotion'),
                                    content: DropdownButton<String>(
                                      value: dropdownValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          dropdownValue = value!;
                                        });
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      items: emotionsList
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.emoji_emotions,
                              size: 30,
                              color: Colors.yellowAccent,
                            ),
                          )
                        ]
                                ),
                              ),
                            ),
                            Text(image.item2),
                          ],
                        );
                      },
                    );
                  }).toList(),
                )
              else
                const Text(
                  "",
                  style: TextStyle(fontSize: 20),
                ),
              Text(enteredText), // Display the entered text
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> displayEmotionBox() {
    controller.clear();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add emotion"),
        content: TextField(
          onSubmitted: (value) {
            Navigator.pop(context, value); // Return the entered text
          },
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter an emotion",
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text); // Return the entered text
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

}
