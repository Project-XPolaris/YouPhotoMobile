import 'package:flutter/material.dart';

class ImageDownloadProgressDialog extends StatelessWidget {
  final int total;
  final int current;
  final String currentName;

  ImageDownloadProgressDialog({
    required this.total,
    required this.current,
    required this.currentName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Image Download Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Downloading $currentName'),
          LinearProgressIndicator(
            value: current / total,
            minHeight: 20.0,
          ),
          SizedBox(height: 10.0),
          Text('Downloaded $current out of $total'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // You can implement actions like cancel or close here
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
