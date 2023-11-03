import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class DragTargetMarkerLayer extends StatelessWidget {
  final List<Marker> markers;
  final GlobalKey? dragTargetKey;

  const DragTargetMarkerLayer(
      {super.key, required this.markers, this.dragTargetKey});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DragTarget(
            key: dragTargetKey,
            builder: (builder, candidates, rejected) {
              return const SizedBox.expand();
            }),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
