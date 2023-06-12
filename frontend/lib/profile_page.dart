import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool isEditing = true;
  String name = "";
  String place = "";
  String carers = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _carersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _placeController.text = place;
    _carersController.text = carers;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _carersController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        _nameController.text = name;
        _placeController.text = place;
        _carersController.text = carers;
      }
    });
  }

  void saveChanges() {
    setState(() {
      name = _nameController.text;
      place = _placeController.text;
      carers = _carersController.text;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
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

class Field extends StatelessWidget {
  final String labelText;
  final String text;
  final bool isEditing;
  final TextEditingController controller;
  const Field(
      {required this.labelText,
      required this.text,
      required this.isEditing,
      required this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          labelText,
          style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 53, 113, 217)),
        ),
        const SizedBox(height: 8.0),
        isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter $labelText',
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16.0),
              ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
