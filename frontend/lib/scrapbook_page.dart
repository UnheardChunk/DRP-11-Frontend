import 'package:flutter/material.dart';
import 'chapter_form.dart';

class ScrapbookPage extends StatelessWidget {
  final String name;

  const ScrapbookPage({Key? key, required this.name}) : super(key: key);

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
              ChapterForm(), // Form for "Chapter" tab
              ChapterForm(), // Form for "Senses" tab
            ],
          ),
        ),
      ),
    );
  }
}
