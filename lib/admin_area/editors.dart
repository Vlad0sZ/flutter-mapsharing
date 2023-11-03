import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharing_map/data/map_data.dart';

class EventNotifier extends ValueNotifier<MapEvent?> {
  EventNotifier(super.value);

  void sendEvent(MapEvent event) => value = event;
}

abstract class ZoneEditor extends ValueNotifier<MapData> {
  ZoneEditor(super.value);

  void addZoneToList(LatLng firstPoint);

  void removeSelectedZone();

  void selectZoneAt(int index);

  void clearSelection();

  void addPointToSelectedZone(LatLng point);

  void movePointAt(int pointIndex, LatLng newPoint);

  void removePointAt(int pointIndex);

  List<LatLng> getActiveMarkers();

  int getSelectedZoneIndex();

  int getZoneLength();
}

class BigZoneEditor extends ZoneEditor {
  int _activeZone = -1;

  BigZoneEditor(super.value);

  @override
  void addZoneToList(LatLng firstPoint) {
    final listOfHoles = _getHolesOrThrow();
    if (listOfHoles.isNotEmpty && listOfHoles.last.isEmpty) {
      listOfHoles.last.add(firstPoint);
    } else {
      listOfHoles.add([firstPoint]);
    }

    _activeZone = listOfHoles.length - 1;
    notifyListeners();
  }

  @override
  void removeSelectedZone() {
    if (_activeZone < 0) return;
    final listOfHoles = _getHolesOrThrow();

    if (listOfHoles.length <= _activeZone) return;

    int removedIndex = _activeZone;
    listOfHoles.removeAt(removedIndex);

    if (_activeZone >= listOfHoles.length) {
      _activeZone = listOfHoles.length - 1;
    }

    notifyListeners();
  }

  @override
  void selectZoneAt(int index) {
    final listOfHoles = _getHolesOrThrow();

    if (index < 0 || index >= listOfHoles.length) {
      throw Exception(
          "Index was out of range $index. Min is 0, max is ${listOfHoles.length - 1}");
    }

    _activeZone = index;
    notifyListeners();
  }

  @override
  int getSelectedZoneIndex() => _activeZone;

  @override
  int getZoneLength() => _getHolesOrThrow().length;

  @override
  void clearSelection() {
    _activeZone = -1;
    notifyListeners();
  }

  @override
  void addPointToSelectedZone(LatLng point) {
    if (_activeZone < 0) return;
    final holes = _getHolesOrThrow();

    holes[_activeZone].add(point);
    notifyListeners();
  }

  @override
  void movePointAt(int pointIndex, LatLng newPoint) {
    if (_activeZone < 0) return;
    final holes = _getHolesOrThrow();
    final hole = holes[_activeZone];
    if (hole.isEmpty || hole.length <= pointIndex) return;
    hole[pointIndex] = newPoint;
    notifyListeners();
  }

  @override
  void removePointAt(int pointIndex) {
    if (_activeZone < 0) return;
    final holes = _getHolesOrThrow();

    final hole = holes[_activeZone];
    if (hole.isEmpty || hole.length <= pointIndex) return;
    hole.removeAt(pointIndex);

    if (hole.isEmpty) {
      removeSelectedZone();
    }

    notifyListeners();
  }

  @override
  List<LatLng> getActiveMarkers() {
    if (_activeZone < 0) return List.empty();
    final holes = _getHolesOrThrow();
    return holes[_activeZone];
  }

  List<List<LatLng>> _getHolesOrThrow() {
    final listOfHoles = value.bigPolygon.holePointsList;

    if (listOfHoles == null) {
      throw Exception("holes in big polygon was null");
    }

    return listOfHoles;
  }
}

class ParkingZoneEditor extends ValueNotifier<MapData> implements ZoneEditor {
  final Color _zoneColor;

  ParkingZoneEditor(super.value, this._zoneColor);

  int _activeIndex = -1;

  @override
  void addZoneToList(LatLng firstPoint) {
    final zones = value.zonePolygons;

    if (zones.isNotEmpty && zones.last.points.isEmpty) {
      zones.last.points.add(firstPoint);
    } else {
      zones.add(Polygon(
        points: [firstPoint],
        color: _zoneColor,
        isFilled: true,
      ));
    }

    _activeIndex = value.zonePolygons.length - 1;
    notifyListeners();
  }

  @override
  int getSelectedZoneIndex() {
    return _activeIndex;
  }

  @override
  void clearSelection() {
    _activeIndex = -1;
    notifyListeners();
  }

  @override
  void removeSelectedZone() {
    if (_activeIndex < 0) return;

    value.zonePolygons.removeAt(_activeIndex);
    notifyListeners();
  }

  @override
  void selectZoneAt(int index) {
    if (index < 0 || index >= value.zonePolygons.length) {
      throw Exception(
          "Index was out of range $index. Min is 0, max is ${value.zonePolygons.length - 1}");
    }

    _activeIndex = index;
    notifyListeners();
  }

  @override
  void addPointToSelectedZone(LatLng point) {
    if (_activeIndex < 0) return;
    var activeZone = value.zonePolygons[_activeIndex];
    activeZone.points.add(point);
    notifyListeners();
  }

  @override
  void movePointAt(int pointIndex, LatLng newPoint) {
    if (_activeIndex < 0) return;
    var activeZone = value.zonePolygons[_activeIndex];
    if (activeZone.points.isEmpty || activeZone.points.length <= pointIndex) {
      return;
    }

    activeZone.points[pointIndex] = newPoint;
    notifyListeners();
  }

  @override
  int getZoneLength() => value.zonePolygons.length;

  @override
  void removePointAt(int pointIndex) {
    if (_activeIndex < 0) return;
    var activeZone = value.zonePolygons[_activeIndex];
    if (activeZone.points.isEmpty || activeZone.points.length <= pointIndex) {
      return;
    }
    activeZone.points.removeAt(pointIndex);
    notifyListeners();
  }

  @override
  List<LatLng> getActiveMarkers() {
    if (_activeIndex < 0) return List.empty();
    var activeZone = value.zonePolygons[_activeIndex];
    return activeZone.points;
  }
}
