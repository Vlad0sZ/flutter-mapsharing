import 'package:sharing_map/data/map_data.dart';

abstract class Database {
  Future<void> init();

  Future<MapData> loadMapData();

  Future<void> updateMapData(MapData mapData);

  static Database? _instance;

  static Future<void> instantiate(Database db) async {
    _instance = db;
    await _instance!.init();
  }

  static Database fromInstance() => _instance!;
}
