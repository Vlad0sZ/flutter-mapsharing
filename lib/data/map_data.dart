import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharing_map/utils/extensions.dart';

/// Класс данных. Содержит в себе
/// Большой полигон [bigPolygon] - в котором редактируются только отверстия
/// Маленькие полигоны-зоны [zonePolygons]
/// Каждый полигон содержит точки (points)
class MapData {
  final Polygon bigPolygon = Polygon(
      points: [
        const LatLng(90, 180),
        const LatLng(-90, 180),
        const LatLng(-90, -180),
        const LatLng(90, -180),
      ],
      color: const Color(0x80000000),
      isFilled: true,
      holePointsList: []);

  final List<Polygon> zonePolygons = [];

  List<Polygon> drawablePolygons() =>
      List.unmodifiable([bigPolygon, ...zonePolygons]);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'big_polygon': bigPolygon.toJson(),
      'zones': zonePolygons.map((e) => e.toJson()).toList(),
    };

    return map;
  }
}
