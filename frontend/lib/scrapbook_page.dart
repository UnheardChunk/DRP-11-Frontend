import 'package:flutter/material.dart';
import 'main.dart';
// import 'package:memories_scrapbook/name_form_page.dart';



class AnotherPage extends StatelessWidget {
  final String name;

  getJSON() async {
    final data = await supabase
        .from('Scapbooks')
        .select('name');
    return data.toString();
  }
  const AnotherPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapbook'),
      ),

      body: Center(

        child: Text("hello $name"),
      ),
    );
  }
}
