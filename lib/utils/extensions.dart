import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

    map['points'] = serializePoints(points);

    if (holePointsList == null) return map;

    List<List<Map<String, dynamic>>> holes = [];
    for (final holeList in holePointsList!) {
      holes.add(serializePoints(holeList));
    }

    map['hole_points'] = holes;
    return map;
  }

  static List<Map<String, dynamic>> serializePoints(List<LatLng> points) {
    List<Map<String, dynamic>> pointsJson = [];
    for (var item in points) {
      pointsJson.add(item.toJson());
    }
    return pointsJson;
  }
}
