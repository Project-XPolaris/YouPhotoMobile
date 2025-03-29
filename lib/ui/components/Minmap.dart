import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMap extends StatelessWidget {
  final LatLng photoLocation;

  const MiniMap({super.key, required this.photoLocation});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: photoLocation,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('photoLocation'),
          position: photoLocation,
        ),
      },
    );
  }
}