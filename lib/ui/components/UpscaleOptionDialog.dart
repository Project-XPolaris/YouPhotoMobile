import 'package:flutter/material.dart';

//RealESRGAN_x4plus
//RealESRNet_x4plus
//RealESRGAN_x4plus_anime_6B
//RealESRGAN_x2plus
//realesr-animevideov3
//realesr-general-x4v3
class UpscaleOptionDialog extends StatefulWidget {
  final Function(String upscaleModel, double outscale,bool faceEnhancement) onUpscaleOptionSelected;
  final initialUpscaleModel;
  final initialOutscale;
  final faceEnhancement;
  const UpscaleOptionDialog({super.key, 

    required this.onUpscaleOptionSelected,
    this.initialUpscaleModel = "RealESRGAN_x4plus",
    this.initialOutscale = 1.5,
    this.faceEnhancement = false
  });

  @override
  State<UpscaleOptionDialog> createState() => _UpscaleOptionDialogState();
}

class _UpscaleOptionDialogState extends State<UpscaleOptionDialog> {
  double outscale = 1.5;
  String upscaleModel = "RealESRGAN_x4plus";
  bool faceEnhancement = true;
  List<String> upscaleModels = [
    "RealESRGAN_x4plus",
    "RealESRNet_x4plus",
    "RealESRGAN_x4plus_anime_6B",
    "RealESRGAN_x2plus",
    "realesr-animevideov3",
    "realesr-general-x4v3"
  ];

  @override
  void initState() {
    outscale = widget.initialOutscale;
    upscaleModel = widget.initialUpscaleModel;
    faceEnhancement = widget.faceEnhancement;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Outscale"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: outscale,
                onChanged: (value) {
                  setState(() {
                    // to x.x
                    outscale = double.parse(value.toStringAsFixed(1));
                    widget.onUpscaleOptionSelected(upscaleModel, outscale,faceEnhancement);
                  });
                },
                min: 1.0,
                max: 4.0,
                divisions: 30,
                label: outscale.toString(),
              ),
            ),
            SizedBox(
              width: 50,
                child: Text(outscale.toString(),textAlign: TextAlign.end,))
          ],
        ),
        Row(
          children: [
            const Expanded(child: Text("Face enhancement")),
            Switch(
              value: faceEnhancement,
              onChanged: (value) {
                setState(() {
                  faceEnhancement = value;
                  widget.onUpscaleOptionSelected(upscaleModel, outscale,faceEnhancement);
                });
              },
            )
          ],
        ),
        const Text("Model"),
        Wrap(
          children: [
            for (String model in upscaleModels)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(model), showCheckmark:false,selected: upscaleModel == model, onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      upscaleModel = model;
                      widget.onUpscaleOptionSelected(upscaleModel, outscale,faceEnhancement);
                    });
                  }
                }),
              )
          ],
        ),

      ],
    );
  }
}
