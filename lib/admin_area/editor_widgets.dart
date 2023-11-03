import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharing_map/ui/drag_marker_layer.dart';
import 'package:sharing_map/ui/pin_point.dart';

import 'editors.dart';

abstract class EditorBuilder extends StatelessWidget {
  final ZoneEditor editorListenable;
  final EventNotifier eventNotifier;

  const EditorBuilder(
      {super.key, required this.editorListenable, required this.eventNotifier});

  void onActivateEditor() => eventNotifier.addListener(onUpdateEvent);

  void onDeactivateEditor() => eventNotifier.removeListener(onUpdateEvent);

  void onUpdateEvent() {
    if (eventNotifier.value != null) {
      onEvent(eventNotifier.value!);
    }
  }

  void onEvent(MapEvent event);
}

class MapZoneEditor extends EditorBuilder {
  final draggableKey = GlobalKey();

  MapZoneEditor(
      {super.key,
      required super.editorListenable,
      required super.eventNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: editorListenable,
      builder: (context, mapData, child) {
        final int totalHoles = editorListenable.getZoneLength();
        final int activeHole = editorListenable.getSelectedZoneIndex();
        return Stack(children: [
          // draw all polygons
          PolygonLayer(
            polygons: mapData.drawablePolygons(),
          ),

          if (totalHoles > 0 && activeHole >= 0)
            DragTargetMarkerLayer(
                dragTargetKey: draggableKey,
                markers: editorListenable
                    .getActiveMarkers()
                    .asMap()
                    .entries
                    .map((entry) => Marker(
                        point: entry.value,
                        child: DraggablePinPoint(
                          color: Colors.yellow,
                          onLongTap: () =>
                              editorListenable.removePointAt(entry.key),
                          draggableKey: draggableKey,
                          onDragCompleted: (offset, accepted) {
                            if (accepted == false) {
                              return;
                            }

                            var camera = MapCamera.of(context);

                            var position = camera
                                .pointToLatLng(Point(offset.dx, offset.dy));
                            editorListenable.movePointAt(entry.key, position);
                          },
                          draggableChild: const SizedBox(
                            width: 30,
                            height: 30,
                            child: CirclePoint(),
                          ),
                        )))
                    .toList()),

          if (totalHoles > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filled(
                          onPressed: _addNewHole, icon: const Icon(Icons.add)),
                      IconButton.filled(
                          onPressed: _removeHole,
                          icon: const Icon(Icons.delete)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      IconButton.filled(
                          onPressed: _nextHole,
                          icon: const Icon(Icons.arrow_back_sharp)),
                      IconButton.filled(
                          onPressed: _prevHole,
                          icon: const Icon(Icons.arrow_forward_sharp)),
                    ],
                  ),
                ),
              ],
            )
        ]);
      },
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void onEvent(MapEvent event) {
    if (event is MapEventTap) {
      _addPointToHole(event.tapPosition);
    }
  }

  void _addPointToHole(LatLng point) {
    var activeHole = editorListenable.getSelectedZoneIndex();
    if (activeHole < 0) {
      editorListenable.addZoneToList(point);
    } else {
      editorListenable.addPointToSelectedZone(point);
    }
  }

  void _addNewHole() => editorListenable.clearSelection();

  void _removeHole() => editorListenable.removeSelectedZone();

  void _nextHole() => _setHoleIndex(1);

  void _prevHole() => _setHoleIndex(-1);

  void _setHoleIndex(int index) {
    final int activeIndex = editorListenable.getSelectedZoneIndex();
    final int newIndex = activeIndex + index;
    final int total = editorListenable.getZoneLength();

    if (newIndex >= total || newIndex < 0) return;
    editorListenable.selectZoneAt(newIndex);
  }
}
