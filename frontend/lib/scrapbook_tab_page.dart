import 'package:flutter/material.dart';
import 'main.dart';

class ScrapbookTabPage extends StatelessWidget {
  final String name;
  const ScrapbookTabPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(child: Text('Chapter')),
                Tab(child: Text('Senses')),
              ],
            ),
            title: Text('$name\'s scrapbook'),
          ),
          body: const TabBarView(
            children: [
              ElevatedButton(
                onPressed: () => {null},
                child: Text('See scrapbook'),
              ),
              Icon(Icons.emoji_emotions)
            ],
          ),
        ),
      ),
    );
  }
}

// class ScrapbookTabPage extends StatelessWidget {
//   final String name;
//
//   const ScrapbookTabPage({Key? key, required this.name}) : super(key: key);
//
//   Future<String> getJSONdata() async {
//     final data = await supabase
//         .from('Scapbooks')
//         .select('name');
//     return data.toString();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$name\'s scrapbook'),
//
//       ),
//
//       body: Center(
//
//           child: ElevatedButton(
//             onPressed: () => getJSONdata(),
//             child: const Text('Get data'),
//           )
//       ),
//     );
//   }
// }

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



