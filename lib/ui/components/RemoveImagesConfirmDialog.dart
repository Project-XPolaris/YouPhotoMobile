import 'package:flutter/material.dart';

class RemoveImagesConfirmDialog extends StatefulWidget {
  final Function(bool deleteImage) onRemove;

  const RemoveImagesConfirmDialog({super.key, required this.onRemove});

  @override
  State<RemoveImagesConfirmDialog> createState() => _RemoveImagesConfirmDialogState();
}

class _RemoveImagesConfirmDialogState extends State<RemoveImagesConfirmDialog> {
  bool deleteImages = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove images'),
      content: Wrap(children: [
        const Text('Are you sure you want to remove these images?'),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: deleteImages,
                onChanged: (bool? value) {
                  setState(() {
                    deleteImages = value!;
                  });
                },
              ),
              const Text('Delete images'),
            ],
          ),
        ),
      ]),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Remove'),
          onPressed: () {
            widget.onRemove(deleteImages);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
