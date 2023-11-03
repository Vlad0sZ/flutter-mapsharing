import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

extension MapExtensions<K, V> on Map<K, V> {
  V? valueOrNull(K key) {
    if (containsKey(key)) {
      return this[key];
    }

    return null;
  }

  V? valueOrDefault(K key, V defaultValue) {
    if (containsKey(key)) {
      return this[key];
    }

    return defaultValue;
  }
}

extension JsonPolygon on Polygon {
  Map<String, dynamic> toJson() {
    final map = {
      'color': color.value,
      'border_width': borderStrokeWidth,
      'border_color': borderColor.value,
      'disable_holes_border': disableHolesBorder,
      'is_dotted': isDotted,
      'is_filled': isFilled,
      'label': label,
    };

    map['points'] = PolygonUtils.serializePoints(points);

    final allHoles = holePointsList;
    if (allHoles != null) {
      map['holes_count'] = allHoles.length;
      for (final (index, item) in allHoles.indexed) {
        map['hole_$index'] = PolygonUtils.serializePoints(item);
      }
    }

    return map;
  }
}

class PolygonUtils {
  static List<Map<String, dynamic>> serializePoints(List<LatLng> points) {
    List<Map<String, dynamic>> pointsJson = [];
    for (var item in points) {
      pointsJson.add(item.toJson());
    }
    return pointsJson;
  }

  static List<LatLng> deserializePoints(dynamic jsonPoints) {
    List<LatLng> points = [];
    for (var item in jsonPoints) {
      points.add(LatLng.fromJson(item));
    }

    return points;
  }

  static Polygon fromJson(Map<String, dynamic> json) {
    final int color = json.valueOrDefault('color', 0xFF00FF00);
    final double borderStrokeWidth = json.valueOrDefault('border_width', 0.0);
    final int borderColor = json.valueOrDefault('border_color', 0xFFFFFF00);
    final bool disableHolesBorder =
        json.valueOrDefault('disable_holes_border', false);
    final bool isDotted = json.valueOrDefault('is_dotted', false);
    final bool isFilled = json.valueOrDefault('is_filled', false);
    final String? label = json.valueOrNull('label');

    if (json.containsKey('points') == false) {
      throw Exception('Can\'t find any points');
    }

    final points = deserializePoints(json['points']);
    List<List<LatLng>> holePointsList = [];

    final countOfHoles = json.valueOrDefault('holes_count', 0);
    for (int i = 0; i < countOfHoles; i++) {
      final holeJson = json.valueOrNull('hole_$i');
      if (holeJson == null) continue;

      holePointsList.add(deserializePoints(holeJson));
    }

    return Polygon(
      points: points,
      color: Color(color),
      borderStrokeWidth: borderStrokeWidth,
      borderColor: Color(borderColor),
      disableHolesBorder: disableHolesBorder,
      isDotted: isDotted,
      isFilled: isFilled,
      label: label,
      holePointsList: holePointsList,
    );
  }
}
