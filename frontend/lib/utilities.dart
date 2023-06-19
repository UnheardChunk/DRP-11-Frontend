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
    required this.noContentText,
  });

  // Future containing data to build GenericTile
  final PostgrestFilterBuilder<List<Map<String, dynamic>>> future;

  // Function to build the GenericTile from a row of the table
  final GenericTile Function(Map<String, dynamic>) genericTileBuilder;

  final String noContentText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        if (data.isNotEmpty) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final row = data[index];
              return genericTileBuilder(row);
            },
        );
        } else {
          return Center(child: Text(noContentText, textScaleFactor: 1.25),);
        }
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

class GenericCircularButton extends StatelessWidget {
  final Widget icon;
  final void Function() onTap;
  final String? text;
  final double size;

  const GenericCircularButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.text,
      required this.size});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ClipOval(
            child: Material(
              color: Colors.blue,
              child: InkWell(
                splashColor: Colors.grey.withOpacity(0.35),
                onTap: onTap,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: icon,
                ),
              ),
            ),
          ),
          if (text != null) Text(text!),
        ],
      );
}

class CustomIcon extends StatelessWidget {
  final double size;
  final String imagePath;
  final Color colour;

  const CustomIcon(
      {super.key,
      required this.size,
      required this.imagePath,
      this.colour = Colors.black});

  @override
  Widget build(BuildContext context) => Container(
        height: size,
        padding: const EdgeInsets.all(15),
        child: Image.asset(
          imagePath,
          filterQuality: FilterQuality.high,
          color: colour,
        ),
      );
}

class GenericModalBottomSheetChild extends StatelessWidget {
  final Widget child;
  final double heightScale;

  const GenericModalBottomSheetChild(
      {super.key, required this.child, required this.heightScale});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height * heightScale,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close),
                onPressed: Navigator.of(context).pop,
              ),
            ),
            child,
          ],
        ),
      );
}

class GenericGrid extends StatelessWidget {
  final List<List<Widget>> rowChildren;

  const GenericGrid({super.key, required this.rowChildren});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (List<Widget> row in rowChildren)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row,
            ),
        ],
      );
}
