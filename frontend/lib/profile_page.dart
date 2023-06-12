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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _placeController.text = place;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        _nameController.text = name;
        _placeController.text = place;
      }
    });
  }

  void saveChanges() {
    setState(() {
      name = _nameController.text;
      place = _placeController.text;
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
        const Text(
          'Name ',
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 53, 113, 217)),
        ),
        const SizedBox(height: 8.0),
        isEditing
            ? TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              )
            : Text(
                name,
                style: const TextStyle(fontSize: 16.0),
              ),
        const SizedBox(height: 8.0),

        // Where I live --------------------------------------------------------
        const Text(
          'Where I live (area not the full address)',
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 53, 113, 217)),
        ),
        const SizedBox(height: 8.0),
        isEditing
            ? TextField(
                controller: _placeController,
                decoration: const InputDecoration(
                  hintText: 'Enter where you live',
                ),
              )
            : Text(
                place,
                style: const TextStyle(fontSize: 16.0),
              ),

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
