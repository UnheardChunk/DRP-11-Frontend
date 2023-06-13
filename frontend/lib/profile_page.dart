import 'package:flutter/material.dart';
import 'utilities.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool isEditing = false;

  final int count = 22;
  final List<String> textFields = List.generate(22, (index) => "");
  final List<TextEditingController> controllers =
      List.generate(22, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < count; i++) {
      controllers[i].text = textFields[i];
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < count; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        for (int i = 0; i < count; i++) {
          controllers[i].text = textFields[i];
        }
      }
    });
  }

  void saveChanges() {
    setState(() {
      for (int i = 0; i < count; i++) {
        textFields[i] = controllers[i].text;
      }
      isEditing = false;
    });
    // Send to database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[300],
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SectionHeader(
                  text: 'About Me', icon: Icon(Icons.portrait_sharp)),
              // Name ----------------------------------------------------------------
              Field(
                  labelText: 'Name',
                  text: textFields[0].isEmpty ? "Not provided" : textFields[0],
                  isEditing: isEditing,
                  controller: controllers[0]),

              // Where I live --------------------------------------------------------
              Field(
                  labelText: 'Where I live (area not the full address)',
                  text: textFields[1].isEmpty ? "Not provided" : textFields[1],
                  isEditing: isEditing,
                  controller: controllers[1]),

              // Carers --------------------------------------------------------------
              Field(
                  labelText: 'The carers/people who know me the best',
                  text: textFields[2].isEmpty ? "Not provided" : textFields[2],
                  isEditing: isEditing,
                  controller: controllers[2]),

              // I would like you to know --------------------------------------------
              Field(
                labelText: 'I would like you to know',
                text: textFields[3].isEmpty ? "Not provided" : textFields[3],
                isEditing: isEditing,
                controller: controllers[3],
              ),

              // Personal History ----------------------------------------------------
              Field(
                  labelText:
                      'My personal history, family and friends, pets and any treasured possessions',
                  text: textFields[4].isEmpty ? "Not provided" : textFields[4],
                  isEditing: isEditing,
                  controller: controllers[4]),

              const SectionHeader(
                  text: 'My Background', icon: Icon(Icons.house_rounded)),

              // Cultural and Religious Background ---------------------------------
              Field(
                  labelText: 'My cultural, religious and spiritual background',
                  text: textFields[5].isEmpty ? "Not provided" : textFields[5],
                  isEditing: isEditing,
                  controller: controllers[5]),

              // Interests and jobs
              Field(
                  labelText: 'My interests, jobs and achievments',
                  text: textFields[6].isEmpty ? "Not provided" : textFields[6],
                  isEditing: isEditing,
                  controller: controllers[6]),

              // Favourite Places --------------------------------------------------
              Field(
                  labelText: 'Favourite placed I have lived and visted',
                  text: textFields[7].isEmpty ? "Not provided" : textFields[7],
                  isEditing: isEditing,
                  controller: controllers[7]),

              const SectionHeader(
                  text: 'My habits and routines',
                  icon: Icon(Icons.access_alarm_sharp)),

              // Routines ----------------------------------------------------------
              Field(
                  labelText: 'The following routines are important to me',
                  text: textFields[8].isEmpty ? "Not provided" : textFields[8],
                  isEditing: isEditing,
                  controller: controllers[8]),

              // Things for myself -------------------------------------------------
              Field(
                  labelText: 'Things I like to do for myself',
                  text: textFields[9].isEmpty ? "Not provided" : textFields[9],
                  isEditing: isEditing,
                  controller: controllers[9]),

              // Things I need help with -------------------------------------------
              Field(
                  labelText: 'Things I might want help with',
                  text: textFields[10].isEmpty ? "Not provided" : textFields[10],
                  isEditing: isEditing,
                  controller: controllers[10]),

              // Things that upset
              Field(
                  labelText: 'Things that may worry or upset me',
                  text: textFields[11].isEmpty ? "Not provided" : textFields[11],
                  isEditing: isEditing,
                  controller: controllers[11]),

              // Makes me feel better
              Field(
                  labelText:
                      'What makes me feel better if I am anxious or upset',
                  text: textFields[12].isEmpty ? "Not provided" : textFields[12],
                  isEditing: isEditing,
                  controller: controllers[12]),

              const SectionHeader(
                  text: 'My communication and mobility',
                  icon: Icon(Icons.chat)),

              // Hearing and eyesight
              Field(
                  labelText: 'My hearing and eyesight',
                  text: textFields[13].isEmpty ? "Not provided" : textFields[13],
                  isEditing: isEditing,
                  controller: controllers[13]),

              // How to communicate ----------------------------------------------
              Field(
                  labelText: 'How we can communicate',
                  text: textFields[14].isEmpty ? "Not provided" : textFields[14],
                  isEditing: isEditing,
                  controller: controllers[14]),

              // Mobility --------------------------------------------------------
              Field(
                  labelText: 'My mobility',
                  text: textFields[15].isEmpty ? "Not provided" : textFields[15],
                  isEditing: isEditing,
                  controller: controllers[15]),

              const SectionHeader(
                  text: 'My personal habits', icon: Icon(Icons.shower_sharp)),

              // Things to help sleep --------------------------------------------
              Field(
                  labelText: 'Things that help me sleep',
                  text: textFields[16].isEmpty ? "Not provided" : textFields[16],
                  isEditing: isEditing,
                  controller: controllers[16]),

              // Personal care ---------------------------------------------------
              Field(
                  labelText: 'My personal care',
                  text: textFields[17].isEmpty ? "Not provided" : textFields[17],
                  isEditing: isEditing,
                  controller: controllers[17]),

              // Medication ------------------------------------------------------
              Field(
                  labelText: 'How I take my medication',
                  text: textFields[18].isEmpty ? "Not provided" : textFields[18],
                  isEditing: isEditing,
                  controller: controllers[18]),

              // Eating and drinking ---------------------------------------------
              Field(
                  labelText: 'My eating and drinking',
                  text: textFields[19].isEmpty ? "Not provided" : textFields[19],
                  isEditing: isEditing,
                  controller: controllers[19]),

              const SectionHeader(text: 'Other', icon: Icon(Icons.info)),

              // Other notes -----------------------------------------------------
              Field(
                  labelText: 'Other notes about me',
                  text: textFields[20].isEmpty ? "Not provided" : textFields[20],
                  isEditing: isEditing,
                  controller: controllers[20]),

              // Date completed
              Field(
                  labelText: 'Date Completed',
                  text: textFields[21].isEmpty ? "Not provided" : textFields[21],
                  isEditing: isEditing,
                  controller: controllers[21]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            isEditing ? saveChanges() : toggleEdit();
          },
          child: isEditing ? const Text('Save') : const Icon(Icons.edit)),
    );
  }
}
