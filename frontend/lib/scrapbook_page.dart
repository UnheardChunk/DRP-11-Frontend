import 'package:flutter/material.dart';
import 'chapter_form.dart';

class ScrapbookPage extends StatefulWidget {
  final String name;

  const ScrapbookPage({Key? key, required this.name}) : super(key: key);

  @override
  State<ScrapbookPage> createState() => _ScrapbookPageState();
}

class _ScrapbookPageState extends State<ScrapbookPage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.name}\'s scrapbook'),
            centerTitle: true,
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(child: Text('Chapter')),
                // Tab(child: Text('Senses')),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ChapterForm(), // Form for "Chapter" tab
              // ChapterForm(), // Form for "Senses" tab
            ],
          ),
        ),
      ),
    );
  }
}
