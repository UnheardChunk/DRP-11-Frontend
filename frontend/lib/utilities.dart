import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Class defining a generic ListTile
class GenericTile extends StatelessWidget {

  // Name of the tile
  final String name;
  final Icon tileIcon;
  final Widget navigatesTo;
  final Color colour;

  const GenericTile({super.key, required this.name, 
                     required this.tileIcon, required this.navigatesTo,
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
            MaterialPageRoute(
              builder: (context) => navigatesTo
            ),
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