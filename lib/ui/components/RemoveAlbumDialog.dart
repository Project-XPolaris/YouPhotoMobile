import 'package:flutter/material.dart';

class RemoveAlbumDialog extends StatefulWidget {
  final Function(bool) onRemove;

  const RemoveAlbumDialog({super.key, 
    required this.onRemove,
  });

  @override
  State<RemoveAlbumDialog> createState() => _RemoveAlbumDialogState();
}

class _RemoveAlbumDialogState extends State<RemoveAlbumDialog> {
  bool removeImage = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete album"),
      content: Wrap(
        children: [
          const Text("Are you sure you want to delete this album?"),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: removeImage,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        removeImage = value;
                      }
                    });
                  },
                ),
                const Text("Remove images"),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(onPressed: () {
          widget.onRemove(removeImage);
        }, child: const Text("Delete")),
      ],
    );
  }
}
