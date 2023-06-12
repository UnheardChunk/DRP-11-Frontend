import 'package:flutter/material.dart';
import 'utilities.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool isEditing = false;

  String name = "";
  String place = "";
  String carers = "";
  String iWouldLikeYouToKnow = "";
  String personalHistory = "";
  String culture = "";
  String jobs = "";
  String favPlaces = "";
  String routines = "";
  String thingsForMyself = "";
  String help = "";
  String upset = "";
  String better = "";
  String hearing = "";
  String communicate = "";
  String mobility = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _carersController = TextEditingController();
  final TextEditingController _toKnowController = TextEditingController();
  final TextEditingController _personalHistoryController =
      TextEditingController();
  final TextEditingController _cultureController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _favPlacesController = TextEditingController();
  final TextEditingController _routineController = TextEditingController();
  final TextEditingController _thingsForMyselfController =
      TextEditingController();
  final TextEditingController _helpController = TextEditingController();
  final TextEditingController _upsetController = TextEditingController();
  final TextEditingController _betterController = TextEditingController();
  final TextEditingController _hearingController = TextEditingController();
  final TextEditingController _communicateController = TextEditingController();
  final TextEditingController _mobilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _placeController.text = place;
    _carersController.text = carers;
    _toKnowController.text = iWouldLikeYouToKnow;
    _personalHistoryController.text = personalHistory;
    _cultureController.text = culture;
    _jobController.text = jobs;
    _favPlacesController.text = favPlaces;
    _routineController.text = routines;
    _thingsForMyselfController.text = thingsForMyself;
    _helpController.text = help;
    _upsetController.text = upset;
    _betterController.text = better;
    _hearingController.text = hearing;
    _communicateController.text = communicate;
    _mobilityController.text = mobility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _carersController.dispose();
    _toKnowController.dispose();
    _personalHistoryController.dispose();
    _cultureController.dispose();
    _jobController.dispose();
    _favPlacesController.dispose();
    _routineController.dispose();
    _thingsForMyselfController.dispose();
    _helpController.dispose();
    _upsetController.dispose();
    _betterController.dispose();
    _hearingController.dispose();
    _communicateController.dispose();
    _mobilityController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        _nameController.text = name;
        _placeController.text = place;
        _carersController.text = carers;
        _toKnowController.text = iWouldLikeYouToKnow;
        _personalHistoryController.text = personalHistory;
        _cultureController.text = culture;
        _jobController.text = jobs;
        _favPlacesController.text = favPlaces;
        _routineController.text = routines;
        _thingsForMyselfController.text = thingsForMyself;
        _helpController.text = help;
        _upsetController.text = upset;
        _betterController.text = better;
        _hearingController.text = hearing;
        _communicateController.text = communicate;
        _mobilityController.text = mobility;
      }
    });
  }

  void saveChanges() {
    setState(() {
      name = _nameController.text;
      place = _placeController.text;
      carers = _carersController.text;
      iWouldLikeYouToKnow = _toKnowController.text;
      personalHistory = _personalHistoryController.text;
      culture = _cultureController.text;
      jobs = _jobController.text;
      favPlaces = _favPlacesController.text;
      routines = _routineController.text;
      thingsForMyself = _thingsForMyselfController.text;
      help = _helpController.text;
      upset = _upsetController.text;
      better = _betterController.text;
      hearing = _hearingController.text;
      communicate = _communicateController.text;
      mobility = _mobilityController.text;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.grey[300],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SectionHeader(
                text: 'About Me', icon: Icon(Icons.portrait_sharp)),
            // Name ----------------------------------------------------------------
            Field(
                labelText: 'Name',
                text: name,
                isEditing: isEditing,
                controller: _nameController),

            // Where I live --------------------------------------------------------
            Field(
                labelText: 'Where I live (area not the full address)',
                text: place,
                isEditing: isEditing,
                controller: _placeController),

            // Carers --------------------------------------------------------------
            Field(
                labelText: 'The carers/people who know me the best',
                text: carers,
                isEditing: isEditing,
                controller: _carersController),

            // I would like you to know --------------------------------------------
            Field(
              labelText: 'I would like you to know',
              text: iWouldLikeYouToKnow,
              isEditing: isEditing,
              controller: _toKnowController,
            ),

            // Personal History ----------------------------------------------------
            Field(
                labelText:
                    'My personal history, family and friends, pets and any treasured possessions',
                text: personalHistory,
                isEditing: isEditing,
                controller: _personalHistoryController),

            const SectionHeader(
                text: 'My Background', icon: Icon(Icons.house_rounded)),

            // Cultural and Religious Background ---------------------------------
            Field(
                labelText: 'My cultural, religious and spiritual background',
                text: culture,
                isEditing: isEditing,
                controller: _cultureController),

            // Interests and jobs
            Field(
                labelText: 'My interests, jobs and achievments',
                text: jobs,
                isEditing: isEditing,
                controller: _jobController),

            // Favourite Places --------------------------------------------------
            Field(
                labelText: 'Favourite placed I have lived and visted',
                text: favPlaces,
                isEditing: isEditing,
                controller: _favPlacesController),

            const SectionHeader(
                text: 'My habits and routines',
                icon: Icon(Icons.access_alarm_sharp)),

            // Routines ----------------------------------------------------------
            Field(
                labelText: 'The following routines are important to me',
                text: routines,
                isEditing: isEditing,
                controller: _routineController),

            // Things for myself -------------------------------------------------
            Field(
                labelText: 'Things I like to do for myself',
                text: thingsForMyself,
                isEditing: isEditing,
                controller: _thingsForMyselfController),

            // Things I need help with -------------------------------------------
            Field(
                labelText: 'Things I might want help with',
                text: help,
                isEditing: isEditing,
                controller: _helpController),

            // Things that upset
            Field(
                labelText: 'Things that may worry or upset me',
                text: upset,
                isEditing: isEditing,
                controller: _upsetController),

            // Makes me feel better
            Field(
                labelText: 'What makes me feel better if I am anxious or upset',
                text: better,
                isEditing: isEditing,
                controller: _upsetController),

            const SectionHeader(
                text: 'My communication and mobility', icon: Icon(Icons.chat)),

            // Hearing and eyesight
            Field(
                labelText: 'My hearing and eyesight',
                text: hearing,
                isEditing: isEditing,
                controller: _hearingController),

            // How to communicate ----------------------------------------------
            Field(
                labelText: 'How we can communicate',
                text: communicate,
                isEditing: isEditing,
                controller: _communicateController),

            // Mobility --------------------------------------------------------
            Field(
                labelText: 'My mobility',
                text: mobility,
                isEditing: isEditing,
                controller: _mobilityController),
            // Edit button -----------------------------------------------------
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: toggleEdit,
                  child: Text(isEditing ? 'Cancel' : 'Edit'),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: saveChanges,
                    child: const Text('Save'),
                  )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
