import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:sharing_map/data/map_data.dart';
import 'package:sharing_map/database/db.dart';
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

  MapData mapData = MapData.defaultData();
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

    _loadDataFuture = _loadDataFromDatabase();

    _changeEditor(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map editor"),
      ),
      body: FutureBuilder<MapData>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(children: [
              _drawFlutterMap(context),
              Opacity(
                opacity: 0.6,
                child: ModalBarrier(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircularProgressIndicator(),
                    Text('Wait for loading...'),
                  ],
                ),
              ),
            ]);
          }

          return Stack(
            children: [
              Row(
                children: [
                  NavigationRail(
                    selectedIndex: _activeEditor,
                    groupAlignment: -0.95,
                    labelType: NavigationRailLabelType.selected,
                    onDestinationSelected: _changeEditor,
                    destinations: const [
                      NavigationRailDestination(
                          icon: Icon(Icons.map_rounded),
                          label: Text("Background")),
                      NavigationRailDestination(
                          icon: Icon(Icons.polyline_rounded),
                          label: Text("Zones")),
                      NavigationRailDestination(
                          icon: Icon(Icons.pin_drop_rounded),
                          label: Text("Markers")),
                    ],
                    leading: FloatingActionButton(
                      child: const Icon(Icons.save),
                      onPressed: () {
                        setState(() {
                          _loadDataFuture = _updateDataToDatabase(mapData);
                        });
                      },
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: _drawFlutterMap(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _drawFlutterMap(BuildContext context) {
    return FlutterMap(
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.map',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        _builders[_activeEditor],
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
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
  }

  void _mapIsReady() {
    mapController.mapEventStream.listen((event) {
      inspect(event);
      eventNotifier.sendEvent(event);
    });
  }

  void _onMapDataLoaded(MapData mapData) {
    this.mapData = mapData;

    for (var builder in _builders) {
      builder.updateData(this.mapData);
    }
  }

  Future<MapData> _loadDataFromDatabase() {
    return database.loadMapData().then((value) {
      _onMapDataLoaded(value);
      return value;
    }).catchError((e) {
      final snackBar = SnackBar(
        content: Text('Error loading: $e'),
        action: SnackBarAction(
          label: 'Try again',
          onPressed: () {
            setState(() {
              _loadDataFuture = _loadDataFromDatabase();
            });
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return MapData.defaultData();
    });
  }

  Future<MapData> _updateDataToDatabase(MapData data) {
    return database
        .updateMapData(mapData)
        .then((value) => {print('success save')})
        .catchError((e) {print('error save $e');})
        .then((value) => data);
  }
}
