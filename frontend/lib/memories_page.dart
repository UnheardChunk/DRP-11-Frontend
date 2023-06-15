import 'dart:typed_data';
import 'chapters_page.dart';
import 'utilities.dart';
import 'package:tuple/tuple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class MemoriesPage extends StatefulWidget {
  final String name;
  final List<String> bucketIds;
  final MemoryOrganisationType organisationType;
  final String emotion;

  const MemoriesPage(this.bucketIds, this.organisationType,
      {super.key, this.emotion = "", required this.name});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Tuple2<Future<Uint8List>, Map<String, dynamic>>> images = [];

  final ImagePicker picker = ImagePicker();
  late TextEditingController captionController;
  late TextEditingController responseController;
  late List<String> emotionsList;

  late VideoPlayerController _videoPlayerController;
  late File _video;


  Future _pickVideo() async {
    final video = await picker.pickVideo(source: ImageSource.gallery);
    _video = File(video!.path);
    _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
      setState(() {

      });
      _videoPlayerController.play();
    });

    await createCaption(_video as XFile?);

  }

  static const iconSize = 75.0;

  @override
  void initState() {
    super.initState();
    captionController = TextEditingController();
    responseController = TextEditingController();
    initialise();
  }

  Future<void> fetchChapterMemories(String bucketId, FileObject path) async {
    final metadata = await supabase
        .from("Files")
        .select()
        .eq("bucket_id", bucketId)
        .eq("name", path.name)
        .single();
    setState(() {
      images.add(Tuple2(
          supabase.storage.from(bucketId).download(path.name), metadata));
    });
  }

  Future<void> fetchEmotionMemories(
      String bucketId, FileObject path, String emotion) async {
    final metadata = await supabase
        .from("Files")
        .select<Map<String, dynamic>?>()
        .eq("bucket_id", bucketId)
        .eq("name", path.name)
        .eq("emotion", emotion)
        .maybeSingle();
    if (metadata == null) return;

    setState(() {
      images.add(Tuple2(
          supabase.storage.from(bucketId).download(path.name), metadata));
    });
  }

  Future<void> fetchMemories(String bucketId) async {
    final paths = await supabase.storage.from(bucketId).list();
    final List<Map<String, dynamic>> emotions =
        await supabase.from("Emotions").select();
    emotionsList = (emotions.map((e) => e["emotion"] as String)).toList();

    for (FileObject path in paths) {
      switch (widget.organisationType) {
        case MemoryOrganisationType.chapters:
          await fetchChapterMemories(bucketId, path);
          break;
        default:
          await fetchEmotionMemories(bucketId, path, widget.emotion);
      }
    }
  }

  void initialise() async {
    widget.bucketIds.forEach(fetchMemories);
  }

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    await createCaption(img);
  }

  Future getVideo(ImageSource media) async {
    var img = await picker.pickVideo(source: media);

    await createCaption(img);
  }


  void uploadImage(XFile? img, String caption, String bucketId) async {
    await supabase.storage.from(bucketId).upload(img!.name, File(img.path));
    await supabase
        .from("Files")
        .insert({"bucket_id": bucketId, "name": img.name, "caption": caption});
    setState(() {
      images.add(Tuple2(img.readAsBytes(), <String, dynamic>{
        "caption": caption,
        "name": img.name,
        "emotion": "No Emotion",
        "response": null
      }));
    });
    if (context.mounted) Navigator.of(context).pop(captionController.text);
  }

  Future createCaption(XFile? img) {
    captionController.clear();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add caption"),
        content: TextField(
          onSubmitted: (_) =>
              uploadImage(img, captionController.text, widget.bucketIds[0]),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter a caption",
          ),
          controller: captionController,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                uploadImage(img, captionController.text, widget.bucketIds[0]),
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
  void chooseImageUploadType() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return GenericModalBottomSheetChild(
          heightScale: 0.2,
          child: GenericGrid(
            rowChildren: [
              [
                GenericCircularButton(
                  size: iconSize,
                  icon: const Icon(
                    Icons.image,
                    size: iconSize * 0.75,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.gallery);
                  },
                  text: "Gallery",
                ),
                GenericCircularButton(
                  size: iconSize,
                  icon: const Icon(
                    Icons.camera_alt,
                    size: iconSize * 0.75,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.camera);
                  },
                  text: "Camera",
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  late List<CameraDescription> cameras;
  CameraController? _cameraController;

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    // Choose the desired camera, e.g., cameras[0] for the back camera
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);

    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await _cameraController!.startVideoRecording();
    } catch (e) {
      // print(e);
    }
  }

  void disposeCamera() {
    _cameraController?.dispose();
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
                        items: emotionsList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  content: TextField(
                    onSubmitted: (_) => createResponse(
                        dropdownValue, metadata["name"], metadata["bucket_id"]),
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: "Enter a response to this memory"),
                    controller: responseController,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => createResponse(dropdownValue,
                          metadata["name"], metadata["bucket_id"]),
                      child: const Text("Submit"),
                    ),
                  ],
                )));
  }

  void createResponse(String emotion, String path, String bucketId) async {
    await supabase
        .from("Files")
        .update({"response": responseController.text, "emotion": emotion})
        .eq("bucket_id", bucketId)
        .eq("name", path);
    if (context.mounted) {
      Navigator.of(context).pop(Tuple2(responseController.text, emotion));
    }
  }

  void chooseVideoUploadType() {
    Navigator.of(context).pop();
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return GenericModalBottomSheetChild(
              heightScale: 0.2,
              child: GenericGrid(
                rowChildren: [
                  [
                    GenericCircularButton(
                      size: iconSize,
                      icon: const Icon(
                        Icons.image,
                        size: iconSize * 0.75,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        //getVideo(ImageSource.gallery)
                        _pickVideo();
                      },
                      text: "Gallery",
                    ),
                    GenericCircularButton(
                      size: iconSize,
                      icon: const Icon(
                        Icons.videocam,
                        size: iconSize * 0.75,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        // initializeCamera();
                        getVideo(ImageSource.camera);
                      },
                      text: "Record video",
                    )
                  ]
                ],
              ));
        });
  }

  void chooseSoundUploadType() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (context) => GenericModalBottomSheetChild(
        heightScale: 0.2,
        child: GenericGrid(
          rowChildren: [
            [
              GenericCircularButton(
                size: iconSize,
                icon: const Icon(
                  Icons.upload,
                  size: iconSize * 0.75,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "Upload sound",
              ),
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                  size: iconSize * 0.75,
                  imagePath: "assets/youtube.png",
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "YouTube",
              ),
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                    size: iconSize * 0.75, imagePath: "assets/microphone.png"),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "Record",
              ),
            ],
          ],
        ),
      ),
    );
  }

  void openMemoryUploading() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (context) => GenericModalBottomSheetChild(
        heightScale: 0.4,
        child: GenericGrid(
          rowChildren: [
            [
              GenericCircularButton(
                size: iconSize,
                icon: const Icon(
                  Icons.image,
                  size: iconSize * 0.75,
                ),
                onTap: chooseImageUploadType,
                text: "Image",
              ),
              GenericCircularButton(
                  size: iconSize,
                  icon: const Icon(
                    Icons.videocam,
                    size: iconSize * 0.75,
                  ),
                  onTap: chooseVideoUploadType,
                  text: "Video"),
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                  size: iconSize * 0.75,
                  imagePath: "assets/text.png",
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "Text",
              ),
            ],
            [
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                  size: iconSize * 0.75,
                  imagePath: "assets/sound.png",
                ),
                onTap: chooseSoundUploadType,
                text: "Sound",
              ),
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                  size: iconSize * 0.75,
                  imagePath: "assets/smell.png",
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "Smell",
              ),
              GenericCircularButton(
                size: iconSize,
                icon: const CustomIcon(
                  size: iconSize * 0.75,
                  imagePath: "assets/taste.png",
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO
                },
                text: "Taste",
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton:
          widget.organisationType == MemoryOrganisationType.chapters
              ? FloatingActionButton(
                  onPressed: openMemoryUploading,
                  child: const Icon(Icons.add),
                )
              : Container(),
      appBar: AppBar(
        title: Text('${widget.name} Memories'),
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
                          return Column(children: [
                            Stack(children: [
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
                                      final response =
                                          await openResponseCreation(
                                              image.item2);
                                      if (response == null) return;

                                      setState(() {
                                        image.item2["response"] =
                                            response.item1;
                                        image.item2["emotion"] = response.item2;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.edit_note,
                                      size: 30,
                                    )),
                              ),
                            ]),
                            Text(image.item2["caption"]),
                            const SizedBox(
                              height: 25,
                            ),
                          ]);
                        });
                  }).toList(),
                ),
              )
            : Container(),
      ),
    );
  }
}
