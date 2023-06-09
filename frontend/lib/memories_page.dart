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
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Tuple2<Future<Uint8List>, String>> images = [];

  final ImagePicker picker = ImagePicker();
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    initialise();
  }

  initialise() async {
    final paths = await supabase.storage.from(widget.bucketId).list();
    for (FileObject path in paths) {
      setState(() {
        images.add(Tuple2(supabase.storage.from(widget.bucketId).download(path.name), path.name));
      });
    }
  }

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    await displayBox(img);
  }

  uploadImage(XFile? img, String caption) async {
    await supabase.storage.from(widget.bucketId).upload(caption, File(img!.path));
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
        onSubmitted: (_) => uploadImage(img, controller.text),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Enter a caption",
        ),
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () => uploadImage(img, controller.text),
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
                ElevatedButton(
                  onPressed: () {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: mediaAlert,
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
                                child: CircularProgressIndicator());
                          }
                          final img = snapshot.data!;
                          return Column(
                            children: <Widget> [Padding(
                              padding: const EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
                              child:
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    img,
                                    fit: BoxFit.fitWidth,
                                    width: MediaQuery.of(context).size.width,
                                    //height: 700,
                                  ),
                                ),
                            ),
                             Text(image.item2),
                          ]
                          );
                        });
                  }).toList(),
                  // Textfield(
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     hintText: 'Enter',
                  //   )
                  // )
                )
              else
                const Text(
                  "",
                  style: TextStyle(fontSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
