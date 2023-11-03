import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';


class Locator {

  Future<Position> getPositionWith(
      {required LocationAccuracy accuracy, int timeoutInSeconds = 15}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location service are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: Duration(seconds: timeoutInSeconds)
    );
  }

  Future<Position> getPosition() async {
    return await getPositionWith(
        accuracy: LocationAccuracy.high,
        timeoutInSeconds: 10
    );
  }

  Future<Position?> getLastKnownPosition() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return await Geolocator.getLastKnownPosition();
    }

    return await getPositionWith(accuracy: LocationAccuracy.best);
  }
}
