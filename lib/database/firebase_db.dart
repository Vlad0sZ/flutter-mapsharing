import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharing_map/data/map_data.dart';
import 'package:sharing_map/database/db.dart';

class FirebaseDatabase implements Database {
  late FirebaseFirestore db;

  @override
  Future<void> init() async {
    db = FirebaseFirestore.instance;
  }

  @override
  Future<MapData> loadMapData() async {
    var snapshot =
        await db.collection('zones').doc('zwCPIeRN3F3TD9iOeVSc').get();

    if (snapshot.exists == false) {
      throw Exception('document is not exists');
    }

    final data = snapshot.data();

    if (data == null || data.containsKey('map_data') == false) {
      return MapData.defaultData();
    }

    var mapDataJson = data['map_data'];
    print('found map data $mapDataJson');
    return MapData.fromJson(mapDataJson);
  }

  @override
  Future<void> updateMapData(MapData mapData) async {
    final Map<String, dynamic> collection = {
      'map_data': mapData.toJson(),
    };

    print(collection);
    await db.collection('zones').doc('zwCPIeRN3F3TD9iOeVSc').update(collection);
  }
}
