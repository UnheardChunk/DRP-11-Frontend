import 'package:flutter/material.dart';
import 'chapter_form.dart';

class ChaptersPage extends StatefulWidget {
  final String name;

  const ChaptersPage({Key? key, required this.name}) : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {

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
                Tab(child: Text('Chapters')),
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
