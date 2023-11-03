import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharing_map/ui/pin_point.dart';
import 'package:url_launcher/url_launcher.dart';

import 'locator.dart';

// https://pub.dev/packages/geolocator
// https://docs.fleaflet.dev/layers/marker-layer
// Карта для расстановки точек
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();

}

class _MapScreenState extends State<MapScreen> {

  static const double maxZoom = 18.0;
  static const double minZoom = 3.0;


  final MapController mapController = MapController();
  final List<MarkerPoint> points = [];
  late Locator _geo;

  @override
  void initState() {
    _geo = Locator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample'),
          elevation: 2,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _goToUserLocation,
          child: const Icon(Icons.navigation),
        ),
        body: DragTarget<MarkerPoint>(
          builder: (context, candidate, reject) =>
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    onMapReady: _mapIsReady,
                    initialCenter: const LatLng(55.160312, 61.370404),
                    initialZoom: 9.2,
                    minZoom: minZoom,
                    maxZoom: maxZoom,
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate
                    )
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.map',
                  ),
                  PolygonLayer(polygons: [
                    Polygon(points: [
                        const LatLng(90, 180),
                        const LatLng(-90, 180),
                        const LatLng(-90, -180),
                        const LatLng(90, -180),
                      ],
                      color: const Color(0x80000000),
                      isFilled: true,
                      holePointsList: []
                    ),
                    Polygon(points: points.map((e) => e.mapPoint).toList(),
                      color: Colors.blue,
                      isFilled: true,
                    ),
                  ]),
                  MarkerLayer(
                      markers: points.map((point) =>
                          Marker(
                              width: 20,
                              height: 20,
                              point: point.mapPoint,
                              child: Draggable<MarkerPoint>(
                                data: point,
                                dragAnchorStrategy: childDragAnchorStrategy,
                                feedback: const CirclePoint(),
                                child: const CirclePoint(),
                                onDragStarted: () {
                                  point.screenPoint = mapController.camera
                                      .latLngToScreenPoint(point.mapPoint);
                                },
                                onDragUpdate: (ev) {
                                  var p = Point(ev.delta.dx, ev.delta.dy);
                                  point.screenPoint += p;
                                },
                                onDragEnd: (ev) {
                                  var updatedPosition = point.screenPoint;
                                  var newLatLng = mapController.camera
                                      .pointToLatLng(updatedPosition);
                                  point.mapPoint = newLatLng;
                                },
                              )
                          )
                      ).toList()
                  ),
                  RichAttributionWidget(attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap',
                      onTap: () =>
                          launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright')),
                    )
                  ]
                  ),
                ],
              ),
        )
    );
  }

  void _mapIsReady() {

    mapController.mapEventStream.listen((event) {
      inspect(event);
      if (event is MapEventTap) {
        setState(() {
          points.add(MarkerPoint.fromLatLng(mapController, event.tapPosition));
        });
      }
    });
  }

  void _goToUserLocation() {
    inspect(points);
    for (var element in points) {
      print(element.mapPoint.toJson());
    }

    _geo.getPosition()
        .then((value) =>
        mapController.move(LatLng(value.latitude, value.longitude), 17))
        .onError((e, stack) {
      print(e);
      return false;
    });
  }
}

class MarkerPoint {
  LatLng mapPoint;
  Point<double> screenPoint;

  MarkerPoint(this.mapPoint, this.screenPoint);

  MarkerPoint.fromScreen(MapController controller, this.screenPoint)
      : mapPoint = controller.camera.pointToLatLng(screenPoint) {
    print('create from screen mp: $mapPoint, sp: $screenPoint');
  }

  MarkerPoint.fromLatLng(MapController controller, this.mapPoint)
      : screenPoint = controller.camera.latLngToScreenPoint(mapPoint) {
    print('create from coords mp: $mapPoint, sp: $screenPoint');
  }
}