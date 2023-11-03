import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharing_map/utils/extensions.dart';

/// Класс данных. Содержит в себе
/// Большой полигон [bigPolygon] - в котором редактируются только отверстия
/// Маленькие полигоны-зоны [zonePolygons]
/// Каждый полигон содержит точки (points)
class MapData {
  final Polygon bigPolygon;
  final List<Polygon> zonePolygons;

  MapData(this.bigPolygon, this.zonePolygons);

  List<Polygon> drawablePolygons() =>
      List.unmodifiable([bigPolygon, ...zonePolygons]);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'big_polygon': bigPolygon.toJson(),
      'zones': zonePolygons.map((e) => e.toJson()).toList(),
    };

    return map;
  }

  factory MapData.fromJson(Map<String, dynamic> json) {
    final Polygon bigPolygon = PolygonUtils.fromJson(json['big_polygon']);
    final List<Polygon> zones = [];

    var listOfZones = json.valueOrDefault('zones', []);
    for (var item in listOfZones) {
      zones.add(PolygonUtils.fromJson(item));
    }

    return MapData(bigPolygon, zones);
  }

  factory MapData.defaultData() {
    final bp = Polygon(
        points: [
          const LatLng(90, 180),
          const LatLng(-90, 180),
          const LatLng(-90, -180),
          const LatLng(90, -180),
        ],
        color: const Color(0x80000000),
        isFilled: true,
        holePointsList: []);

    return MapData(bp, []);
  }
}
