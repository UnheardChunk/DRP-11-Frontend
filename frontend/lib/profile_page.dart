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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _carersController = TextEditingController();
  final TextEditingController _toKnowController = TextEditingController();
  final TextEditingController _personalHistoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _placeController.text = place;
    _carersController.text = carers;
    _toKnowController.text = iWouldLikeYouToKnow;
    _personalHistoryController.text = personalHistory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _carersController.dispose();
    _toKnowController.dispose();
    _personalHistoryController.dispose();
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
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.portrait),
            SizedBox(width: 16.0),
            Text(
              textAlign: TextAlign.start,
              'About me',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 226, 75, 98)),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
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
        // Edit button ---------------------------------------------------------
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
    ));
  }
}
