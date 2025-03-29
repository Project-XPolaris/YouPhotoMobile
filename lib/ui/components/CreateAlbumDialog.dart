import 'package:flutter/material.dart';

class CreateAlbumDialog extends StatefulWidget {
  final Function(String) onCreateAlbum;

  const CreateAlbumDialog({super.key, 
    required this.onCreateAlbum,
  });

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  String inputAlbumName = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create album"),
      content: TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'album Name'),
          onChanged: (value) {
            setState(() {
              inputAlbumName = value;
            });
          }),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              widget.onCreateAlbum(inputAlbumName);
            },
            child: const Text("Create"))
      ],
    );
  }
}
