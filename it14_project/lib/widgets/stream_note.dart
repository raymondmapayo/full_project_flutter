import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:it14_project/data/firestore.dart';
import 'package:it14_project/widgets/task_widget.dart';

class StreamNote extends StatelessWidget {
  final bool done;

  StreamNote(this.done, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreDataSource().stream(done),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {}

        final notesList = FirestoreDataSource().getNotes(snapshot);

        return notesList.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final note = notesList[index];
                        return TaskWidget(note);
                      },
                      itemCount: notesList.length,
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
