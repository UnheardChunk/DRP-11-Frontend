import 'package:flutter/material.dart';
import 'main.dart';

class ScrapbookPage extends StatelessWidget {
  final String name;

  const ScrapbookPage({Key? key, required this.name}) : super(key: key);

  Future<String> getJSONdata() async {
    final data = await supabase
        .from('Scapbooks')
        .select('name');
    return data.toString();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name\'s scrapbook'),

      ),

      body: Center(

          child: ElevatedButton(
            onPressed: () => getJSONdata(),
            child: const Text('Get data'),
          )
      ),
    );
  }
}

// Future<Scaffold> navigateToSensesPage(String name) async {
//   //navigates to new page
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => SensesPage(name: name),
//     ),
//   );
//
//
// }

// class SensesPage {
// }

