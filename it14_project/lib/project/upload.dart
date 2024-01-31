import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:it14_project/const/colors.dart';
import 'package:it14_project/data/firestore.dart';
import 'package:uuid/uuid.dart';

class UpdatePhoto extends StatefulWidget {
  const UpdatePhoto({Key? key}) : super(key: key);

  @override
  State<UpdatePhoto> createState() => _UpdatePhotoState();
}

class _UpdatePhotoState extends State<UpdatePhoto> {
  final TextEditingController title = TextEditingController();
  final TextEditingController subtitle = TextEditingController();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      body: SafeArea(
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) async {
            if (imageFile != null) {
              var uuid = const Uuid().v4();
              _showDeleteConfirmation(context, uuid);
            }
          },
          direction: DismissDirection.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              titleWidget(),
              const SizedBox(height: 20),
              subtitleWidget(),
              const SizedBox(height: 20),
              images(),
              const SizedBox(height: 20),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String noteId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteNoteAndDismiss(noteId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget images() {
    return Container(
      height: 180,
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: custom_green,
                ),
              ),
              width: 140,
              margin: const EdgeInsets.all(8),
              child: _buildImageWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/no-image.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 8),
          const Text('Upload Image'),
        ],
      );
    }
  }

  Widget titleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: title,
          focusNode: _focusNode1,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            hintText: 'Type of Activity',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xffc5c5c5),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: custom_green,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget subtitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          maxLines: 3,
          controller: subtitle,
          focusNode: _focusNode2,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            hintText: 'Description',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xffc5c5c5),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: custom_green,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: custom_green,
            minimumSize: const Size(170, 48),
          ),
          onPressed: () async {
            if (imageFile != null) {
              var uuid = const Uuid().v4();
              await _uploadImage(imageFile!, uuid);
              Navigator.pop(context);
            } else {
              // Show an error message or handle the case where no image is selected.
            }
          },
          child: const Text('Add Task'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            minimumSize: const Size(170, 48),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(File imageFile, String noteId) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$noteId.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();
        print('Image uploaded successfully. Download URL: $downloadURL');
        await FirestoreDataSource()
            .Addnote(subtitle.text, title.text, downloadURL);
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _deleteNoteAndDismiss(String noteId) async {
    try {
      await FirestoreDataSource().delete_note(noteId);
      print('Note deleted successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error deleting note: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting note'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
