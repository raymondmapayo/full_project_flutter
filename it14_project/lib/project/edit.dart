import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:it14_project/const/colors.dart';
import 'package:it14_project/data/firestore.dart';
import 'package:it14_project/model/model_notes.dart';

class Edit extends StatefulWidget {
  final Note _note;
  final Null Function(dynamic status) onStatusChanged;

  Edit(this._note, {Key? key, required this.onStatusChanged}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final TextEditingController title = TextEditingController();
  final TextEditingController subtitle = TextEditingController();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    title.text = widget._note.title;
    subtitle.text = widget._note.subtitle;
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
        await FirestoreDataSource().updateNote(
          widget._note.id,
          title.text,
          subtitle.text,
          downloadURL,
        );
        // Notify the parent or handle the status change as needed
        widget.onStatusChanged('Image uploaded successfully.');
      });
    } catch (e) {
      print('Error uploading image: $e');
      // Handle the error as needed
      widget.onStatusChanged('Error uploading image: $e');
    }
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
    } else if (widget._note.image?.isNotEmpty ?? false) {
      return Image.network(widget._note.image!, fit: BoxFit.cover);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file),
          const SizedBox(height: 8),
          Text('Upload Photo'),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      body: SafeArea(
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
    );
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
          decoration: _buildInputDecoration('Title'),
        ),
      ),
    );
  }

  Padding subtitleWidget() {
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
          decoration: _buildInputDecoration('Subtitle'),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      hintText: hintText,
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
            String imageUrl = widget._note.image ?? '';

            if (imageFile != null) {
              await _uploadImage(imageFile!, widget._note.id);
            } else {
              // If no new image, update other details without uploading
              await FirestoreDataSource().Update(
                widget._note.id,
                title.text,
                subtitle.text,
                imageUrl,
              );
            }

            // Notify the parent or handle the status change as needed
            widget.onStatusChanged('Note updated successfully.');

            Navigator.pop(context);
          },
          child: const Text('Save Changes'),
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
}
