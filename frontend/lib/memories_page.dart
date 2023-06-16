import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
  List<Tuple2<Future<Uint8List>, Map<String, dynamic>>> files = [];

  final ImagePicker picker = ImagePicker();
  late TextEditingController captionController;
  late TextEditingController responseController;
  late List<String> emotionsList;

  late VideoPlayerController _videoPlayerController;
  late File _video;

  Future _pickVideo() async {
    final video = await picker.pickVideo(source: ImageSource.gallery);
    _video = File(video!.path);
    _videoPlayerController = VideoPlayerController.file(_video)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });

    await createCaption(_video, MemoryType.video);
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
      files.add(Tuple2(
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
      files.add(Tuple2(
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
    final img = await picker.pickImage(source: media);

    if (img != null) {
      await createCaption(File(img.path), MemoryType.image);
    }
  }

  Future getVideo(ImageSource media) async {
    final video = await picker.pickVideo(source: media);

    if (video != null) {
      await createCaption(File(video.path), MemoryType.video);
    }
  }

  void uploadFile(
      File file, String caption, String bucketId, MemoryType memoryType) async {
    final fileName = path.basename(file.path);
    await supabase.storage.from(bucketId).upload(fileName, file);
    await supabase.from("Files").insert({
      "bucket_id": bucketId,
      "name": fileName,
      "caption": caption,
      "file_type": memoryType.typeString
    });
    setState(() {
      files.add(Tuple2(file.readAsBytes(), <String, dynamic>{
        "caption": caption,
        "name": fileName,
        "emotion": "No Emotion",
        "response": null,
        "file_type": memoryType.typeString
      }));
    });
    if (context.mounted) Navigator.of(context).pop(captionController.text);
  }

  Future createCaption(File file, MemoryType memoryType) {
    captionController.clear();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add caption"),
        content: TextField(
          onSubmitted: (_) => uploadFile(
              file, captionController.text, widget.bucketIds[0], memoryType),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter a caption",
          ),
          controller: captionController,
        ),
        actions: [
          TextButton(
            onPressed: () => uploadFile(
                file, captionController.text, widget.bucketIds[0], memoryType),
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

  Future<void> getAudioFile() async {
    final audioFile = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (audioFile != null) {
      await createCaption(File(audioFile.files.first.path!), MemoryType.audio);
    }
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
                  getAudioFile();
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

  Future<void> pressResponse(Map<String, dynamic> metadata) async {
    final response = await openResponseCreation(metadata);
    if (response == null) return;

    setState(() {
      metadata["response"] = response.item1;
      metadata["emotion"] = response.item2;
    });
  }

  Widget displayMemory(Uint8List media, Map<String, dynamic> metadata) {
    switch (metadata["file_type"]) {
      case "image":
        return MemoryImage(
          caption: metadata["caption"],
          image: media,
          responseButton: ResponseButton(
            onPressed: () => pressResponse(metadata),
          ),
        );
      case "video":
        break;
      case "audio":
        return MemoryAudio(
          audio: media,
          responseButton: ResponseButton(
            onPressed: () => pressResponse(metadata),
          ),
          caption: metadata["caption"],
        );
      default:
    }
    return Placeholder();
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
        child: files.isNotEmpty
            ? SingleChildScrollView(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: files.map((file) {
                    return FutureBuilder(
                        future: file.item1,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return displayMemory(snapshot.data!, file.item2);
                        });
                  }).toList(),
                ),
              )
            : Container(),
      ),
    );
  }
}

enum MemoryType {
  image("image"),
  video("video"),
  audio("audio"),
  text("text");

  final String typeString;

  const MemoryType(this.typeString);
}

class ResponseButton extends StatelessWidget {
  final void Function() onPressed;

  const ResponseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topRight,
        child: ElevatedButton(
            onPressed: onPressed,
            child: const Icon(
              Icons.edit_note,
              size: 30,
            )),
      );
}

class MemoryImage extends StatelessWidget {
  final Uint8List image;
  final ResponseButton responseButton;
  final String caption;

  const MemoryImage(
      {super.key,
      required this.image,
      required this.responseButton,
      required this.caption});

  @override
  Widget build(BuildContext context) => Column(children: [
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              image,
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          responseButton,
        ]),
        Text(caption),
        const SizedBox(
          height: 25,
        ),
      ]);
}

class MemoryAudio extends StatefulWidget {
  final Uint8List audio;
  final ResponseButton responseButton;
  final String caption;

  const MemoryAudio(
      {super.key,
      required this.audio,
      required this.responseButton,
      required this.caption});

  @override
  State<MemoryAudio> createState() => _MemoryAudioState();
}

class _MemoryAudioState extends State<MemoryAudio> {
  static const double iconSize = 45;

  final audioPlayer = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> setAudioSource() async {
    await audioPlayer.setSourceBytes(widget.audio);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await setAudioSource();
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Duration of song: ${duration.inSeconds}");
    print("Position in song: ${position.inSeconds}");
    return Material(
      child: ListTile(
        leading: GenericCircularButton(
          size: iconSize,
          icon: isPlaying
              ? const Icon(
                  Icons.pause,
                  size: iconSize * 0.75,
                )
              : const Icon(Icons.play_arrow, size: iconSize * 0.75),
          onTap: () async {
            if (isPlaying) {
              await audioPlayer.pause();
            } else {
              await audioPlayer.resume();
            }
          },
        ),
        title: Text(widget.caption),
        subtitle: Slider(
          min: 0,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds.toDouble(),
          onChanged: (value) async {
            setState(() {
              position = Duration(seconds: value.toInt());
            });
            await audioPlayer.seek(position);
          },
        ),
      ),
    );
  }
}
