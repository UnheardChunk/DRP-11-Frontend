import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Class defining a generic ListTile
class GenericTile extends StatelessWidget {
  // Name of the tile
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

// Class defining list view using supabase database
class GenericFutureListView extends StatelessWidget {
  const GenericFutureListView({
    super.key,
    required this.future,
    required this.genericTileBuilder,
  });

  // Future containing data to build GenericTile
  final PostgrestFilterBuilder<List<Map<String, dynamic>>> future;

  // Function to build the GenericTile from a row of the table
  final GenericTile Function(Map<String, dynamic>) genericTileBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final row = data[index];
            return genericTileBuilder(row);
          },
        );
      },
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
        const SizedBox(height: 30),
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
        const SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 16.0),
            Flexible(
              child: Text(
                textAlign: TextAlign.left,
                text,
                style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 226, 75, 98)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}

class GenericContainer extends StatelessWidget {
  const GenericContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}
