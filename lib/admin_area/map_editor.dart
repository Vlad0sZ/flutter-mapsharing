import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:sharing_map/data/map_data.dart';
import 'package:sharing_map/database/db.dart';
import 'package:sharing_map/ui/loading_overlay.dart';
import 'editor_widgets.dart';
import 'editors.dart';

class MapEditor extends StatefulWidget {
  const MapEditor({super.key});

  @override
  State<MapEditor> createState() => _MapEditorState();
}

/*
  Список действий:
  1) Расширение зоны
  2) Редактирование зон


  1) Расширение зоны (дыры в большом полигоне):
    - Добавить точку (тап)
    - Удалить точку (выбрать и тап, лонг-тап)
    - Удалить все точки (кнопка на приборке)
    - Добавить новую дыру (кнопка на приборке)
    - Переключение между дырами (кнопки на приборке)

  2) Редактирование зон (полигоны):
    - Выбрать полигон (из существующих)
    - Добавить точку по клику (создает новый полигон, если не выбран)
    - Удалить точку по клику на нее (удаляет точку у выбранного полигона)
 */

class _MapEditorState extends State<MapEditor> {
  static const double maxZoom = 18.0;
  static const double minZoom = 3.0;


  // map event notifier
  final EventNotifier eventNotifier = EventNotifier(null);

  // map controller
  final MapController mapController = MapController();

  late final Database database;
  late final List<EditorBuilder> _builders;

  late Future<MapData> _loadDataFuture;

  MapData mapData = MapData();
  int _activeEditor = -1;

  @override
  void initState() {
    database = Database.fromInstance();

    _builders = [
      MapZoneEditor(
        eventNotifier: eventNotifier,
        editorListenable: BigZoneEditor(mapData),
      ),
      MapZoneEditor(
        eventNotifier: eventNotifier,
        editorListenable: ParkingZoneEditor(
          mapData,
          const Color(0xB3000000),
        ),
      )
    ];

    _loadDataFuture = database.loadMapData();

    _changeEditor(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map editor"),
      ),
      body: FutureLoadingWidget<MapData>(
        future: _loadDataFuture,
        onCompleted: _onMapDataLoaded,
        onError: _onError,
        loadingWidgetBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        errorWidgetBuilder: (context) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadDataFuture = database.loadMapData();
                });
              },
              child: const Text("Reload"),
            ),
          );
        },
        child: Row(
          children: [
            NavigationRail(
                selectedIndex: _activeEditor,
                labelType: NavigationRailLabelType.selected,
                onDestinationSelected: _changeEditor,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.map_rounded), label: Text("Background")),
                  NavigationRailDestination(
                      icon: Icon(Icons.polyline_rounded), label: Text("Zones")),
                  NavigationRailDestination(
                      icon: Icon(Icons.pin_drop_rounded),
                      label: Text("Markers")),
                ]),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    onMapReady: _mapIsReady,
                    initialCenter: const LatLng(55.160312, 61.370404),
                    initialZoom: 9.2,
                    minZoom: minZoom,
                    maxZoom: maxZoom,
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate)),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.map',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  _builders[_activeEditor],
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap contributors'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  void _changeEditor(int editorIndex) {
    if (editorIndex < 0 || editorIndex >= _builders.length) return;
    if (editorIndex == _activeEditor) return;

    if (_activeEditor >= 0) {
      _builders[_activeEditor].onDeactivateEditor();
    }

    _builders[editorIndex].onActivateEditor();

    setState(() {
      _activeEditor = editorIndex;
    });

    var json = jsonEncode(mapData);
    print(json);
  }

  void _mapIsReady() {
    mapController.mapEventStream.listen((event) {
      inspect(event);
      eventNotifier.sendEvent(event);
    });
  }

  void _onMapDataLoaded(MapData mapData) {
    this.mapData = mapData;
    // todo update listeners;
  }

  Future<void> _onError(error) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text('Something went wrong!'),
                  Text('Error: $error'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('ok!'),
              ),
            ],
          );
        });
  }
}
