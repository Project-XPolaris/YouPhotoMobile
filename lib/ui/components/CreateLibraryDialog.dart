import 'package:flutter/material.dart';

class CreateLibraryDialog extends StatefulWidget {
  final Function(String) onConfirm;


  const CreateLibraryDialog({super.key, 
    required this.onConfirm,
  });

  @override
  State<CreateLibraryDialog> createState() => _CreateLibraryDialogState();
}

class _CreateLibraryDialogState extends State<CreateLibraryDialog> {
  String libraryName = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Library'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                libraryName = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Library Name',
              hintText: 'Enter library name',

            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onConfirm(libraryName);
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}