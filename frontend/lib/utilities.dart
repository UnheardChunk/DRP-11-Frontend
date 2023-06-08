import 'package:flutter/material.dart';

// Class defining a ListTile for a scrapbook
class GenericTile extends StatelessWidget {

  // Name of the scrapbook
  final String name;
  final Icon tileIcon;
  final Widget navigatesTo;

  const GenericTile({super.key, required this.name, 
                       required this.tileIcon, required this.navigatesTo});
  
  @override
  Widget build(BuildContext context) {
    return Card(
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