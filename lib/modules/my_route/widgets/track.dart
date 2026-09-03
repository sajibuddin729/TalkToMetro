

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/modules/my_route/widgets/constant.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  LatLng? currentPosition;
  static const Mirpur = LatLng(23.822350, 90.365417);
  static const Motijheel = LatLng(23.733330, 90.417458);
  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleMapsApiKey,
      request: PolylineRequest(
          mode: TravelMode.driving,
          origin: PointLatLng(Mirpur.latitude, Mirpur.longitude),
          destination: PointLatLng(Motijheel.latitude, Motijheel.longitude)
      ),
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) =>polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {

        });
    }
    }

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
        return Scaffold(
      body: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: Mirpur,
                zoom: 13,
              ),
              polylines: { 
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  // color: Colors.blue,
                  // width: 5
                )
              },
              markers: {
                const Marker(
                  markerId: MarkerId('source'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: Mirpur,
                ),
                const Marker(
                  markerId: MarkerId('destination'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: Motijheel,
                ),
              },
             // polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }
}