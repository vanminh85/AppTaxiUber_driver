import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";

String googleMapKey = "AIzaSyDuDxriw8CH8NbVLiXtKFQ2Nb64AoRSdyg";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(10.798879771962616, 10.66463381075194),
  zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomePage;
