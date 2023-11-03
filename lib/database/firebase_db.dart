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
    await Future.delayed(const Duration(seconds: 4));
    if (Random().nextBool() == true) throw Exception('Wow wow wow!');
    return MapData();
  }

  @override
  Future<void> updateMapData(MapData mapData) async {
    await db
        .collection('map_data')
        .doc('zwCPIeRN3F3TD9iOeVSc')
        .update(mapData.toJson());
  }
}