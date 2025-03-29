
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youphotomobile/api/client.dart';

import '../../api/image.dart';
import '../components/UpscaleOptionDialog.dart';

class UpscaleView extends StatefulWidget {
  final Photo photo;

  const UpscaleView({Key? key, required this.photo}) : super(key: key);

  static launch(BuildContext context, Photo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpscaleView(
                photo: photo,
              )),
    );
  }

  @override
  State<UpscaleView> createState() => _UpscaleViewState();
}

class _UpscaleViewState extends State<UpscaleView> {
  String mode = "original";
  Uint8List? upscaledImage;
  double outscale = 1.5;
  String upscaleModel = "RealESRGAN_x4plus";
  bool upscaleInProgress = false;
  bool faceEnhancement = false;


  void showUpscalingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Prevent back action during upscaling
            return !upscaleInProgress;
          },
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Upscaling image..."),
              ],
            ),
          ),
        );
      },
    );
  }

  upscaleImage() async {
    setState(() {
      upscaledImage = null;
      mode = "original";
      upscaleInProgress = true;
    });
    showUpscalingDialog(
        context); // Show the dialog before starting the upscale process
    try {
      Uint8List resultImage = await ApiClient().upscaleImage(widget.photo.id!,
          modelName: upscaleModel, outscale: outscale,faceEnhancement: faceEnhancement);
      setState(() {
        upscaledImage = resultImage;
        mode = "upscaled";
      });
    } finally {
      Navigator.pop(
          context); // Close the dialog after the upscale process is complete
      setState(() {
        upscaleInProgress = false;
      });
    }
  }

  saveToLibrary() async {
    if (upscaledImage == null) {
      return;
    }
    await ApiClient().uploadImage(upscaledImage!,
        "upscale_" + widget.photo.name!, widget.photo.libraryId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Image saved to library"),
    ));
  }

  setUpscaleParams() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: const Text(
                      "Upscale Options",
                      style: TextStyle(fontSize: 18),
                    )),
                UpscaleOptionDialog(
                  initialOutscale: outscale,
                  initialUpscaleModel: upscaleModel,
                  onUpscaleOptionSelected: (upscaleModel, outscale, faceEnhancement) {
                    setState(() {
                      this.upscaleModel = upscaleModel;
                      this.outscale = outscale;
                      this.faceEnhancement = faceEnhancement;
                    });
                  },
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        upscaleImage();
                      },
                      child: const Text("Upscale")),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upscale'),
          actions: [
            TextButton(
                child: Text(mode == "original" ? "Original" : "Upscale"),
                onPressed: () {
                  if (upscaledImage == null) {
                    return;
                  }
                  if (mode == "original") {
                    setState(() {
                      mode = "upscaled";
                    });
                  } else {
                    setState(() {
                      mode = "original";
                    });
                  }
                }),
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(child: Builder(builder: (context) {
                if (upscaledImage != null && mode == "upscaled") {
                  return PhotoView(
                      minScale: PhotoViewComputedScale.contained,
                      imageProvider: MemoryImage(upscaledImage!),
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ));
                }
                return PhotoView(
                    minScale: PhotoViewComputedScale.contained,
                    imageProvider: NetworkImage(widget.photo.rawUrl),
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ));
              })),
              Container(
                height: 72,
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setUpscaleParams();
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 32,
                        )),
                    upscaledImage != null
                        ? Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: IconButton(
                                onPressed: () {
                                  saveToLibrary();
                                },
                                icon: const Icon(
                                  Icons.save,
                                  size: 32,
                                )),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
