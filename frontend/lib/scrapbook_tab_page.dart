import 'package:flutter/material.dart';
import 'package:memories_scrapbook/scrapbook_form.dart';

class ScrapbookTabPage extends StatelessWidget {
  final String name;

  const ScrapbookTabPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
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
              ScrapbookForm(), // Form for "Chapter" tab
              ScrapbookForm(), // Form for "Senses" tab
            ],
          ),
        ),
      ),
    );
  }
}
