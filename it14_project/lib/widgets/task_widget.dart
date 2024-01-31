import 'package:flutter/material.dart';
import 'package:it14_project/const/colors.dart';
import 'package:it14_project/data/firestore.dart';
import 'package:it14_project/model/model_notes.dart';
import 'package:it14_project/project/edit.dart';

class TaskWidget extends StatefulWidget {
  final Note _note;

  const TaskWidget(this._note, {Key? key}) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget._note.id), // Unique key for each item
      background: _buildDismissBackground(),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteNote();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildText(widget._note.title, 18, FontWeight.bold),
                    const SizedBox(height: 5),
                    _buildText(
                      widget._note.subtitle,
                      16,
                      FontWeight.w400,
                      Color.fromARGB(255, 30, 29, 29),
                    ),
                  ],
                ),
              ),
              _buildTimeAndEditContainers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: NetworkImage(widget._note.image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize, FontWeight fontWeight,
      [Color? color]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTimeAndEditContainers() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimeContainer(),
          const SizedBox(width: 10),
          _buildEditContainer(),
        ],
      ),
    );
  }

  Widget _buildTimeContainer() {
    return Container(
      width: 90,
      height: 28,
      decoration: BoxDecoration(
        color: custom_green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Image.asset('images/icon_time.png'),
            const SizedBox(width: 10),
            Text(
              widget._note.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditContainer() {
    return GestureDetector(
      onTap: _goToEditScreen,
      child: Container(
        width: 90,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xffE2F6F1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Image.asset('images/icon_edit.png'),
              const SizedBox(width: 10),
              const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteNote();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteNote() {
    FirestoreDataSource().delete_note(widget._note.id);
  }

  void _goToEditScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Edit(
          widget._note,
          onStatusChanged: (status) {},
        ),
      ),
    );
  }
}
