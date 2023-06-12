import 'package:flutter/material.dart';

// Class defining a ListTile for a scrapbook
class GenericTile extends StatelessWidget {
  // Name of the scrapbook
  final String name;
  final Icon tileIcon;
  final Widget navigatesTo;
  final Color colour;

  const GenericTile(
      {super.key,
      required this.name,
      required this.tileIcon,
      required this.navigatesTo,
      this.colour = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colour,
      child: ListTile(
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: tileIcon,
        iconColor: Colors.black,
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => navigatesTo),
          )
        },
      ),
    );
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          textAlign: TextAlign.center,
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

class SectionHeader extends StatelessWidget {
  final String text;
  final Icon icon;

  const SectionHeader({
    super.key,
    required this.text,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 16.0),
            Text(
              textAlign: TextAlign.start,
              text,
              style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 226, 75, 98)),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
