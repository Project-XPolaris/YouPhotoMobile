import 'package:flutter/material.dart';
import 'package:youphotomobile/ui/upscale/upscale.dart';

class ViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showUI;
  final String title;

  const ViewerAppBar({
    Key? key,
    required this.showUI,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showUI) return Container();

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == "upscale") {
              // TODO: Implement upscale functionality
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: "upscale",
                child: Text('Upscale'),
              ),
            ];
          },
        )
      ],
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
