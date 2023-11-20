import 'package:flutter/material.dart';

class ImageDownloadProgressDialog extends StatelessWidget {
  final int total;
  final int current;
  final bool isDisplay;

  ImageDownloadProgressDialog({
    required this.total,
    required this.current,
    required this.isDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return isDisplay
        ? AlertDialog(
            title: Text('Image Download Progress'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          )
        : SizedBox.shrink();
  }
}
