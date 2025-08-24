import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youphotomobile/ui/components/Minmap.dart';
import 'package:youphotomobile/util/color.dart';
import 'package:youphotomobile/util/screen.dart';

class InfoPanel extends StatelessWidget {
  final dynamic photoItem;

  const InfoPanel({
    Key? key,
    required this.photoItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
      width: getHalfScreenLength(context),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildInfoSection("Name", photoItem.name ?? ""),
            _buildInfoSection(
              "Resolution",
              "${photoItem.width} x ${photoItem.height}",
            ),
            _buildLocationSection(context),
            _buildTagsSection(),
            _buildColorsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    if (photoItem.lat == null || photoItem.lng == null) {
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Location",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          height: 200,
          child: MiniMap(
            photoLocation: LatLng(photoItem.lat, photoItem.lng),
          ),
        ),
        Text(
          photoItem.address ?? "",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    if (photoItem.tag.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tags",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Wrap(
          spacing: 4,
          children: photoItem.tag.map((item) {
            return Chip(
              padding: const EdgeInsets.all(2),
              label: Text(item.tag ?? ""),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorsSection() {
    if (photoItem.imageColors.isEmpty) {
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: photoItem.imageColors.map((item) {
            return Container(
              width: 96,
              decoration: BoxDecoration(
                color: Color(int.parse(item.value!.replaceAll('#', '0xFF'))),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    item.value ?? "",
                    style: TextStyle(color: getTextColor(item.value!)),
                  ),
                  Text(
                    "${(item.percent! * 100).toStringAsFixed(2)}%",
                    style: TextStyle(color: getTextColor(item.value!)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
