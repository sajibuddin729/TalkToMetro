import 'package:google_maps_flutter/google_maps_flutter.dart';

class MetroStation {
  const MetroStation({
    required this.name,
    required this.position,
  });

  final String name;
  final LatLng position;
}

/// Dhaka Metro Rail Line 6 — north to south (approximate coordinates).
const List<MetroStation> dhakaMetroStations = [
  MetroStation(name: 'Uttara North', position: LatLng(23.8768, 90.3894)),
  MetroStation(name: 'Uttara Center', position: LatLng(23.8695, 90.3890)),
  MetroStation(name: 'Uttara South', position: LatLng(23.8620, 90.3885)),
  MetroStation(name: 'Pallabi', position: LatLng(23.8520, 90.3850)),
  MetroStation(name: 'Mirpur 11', position: LatLng(23.8430, 90.3820)),
  MetroStation(name: 'Mirpur 10', position: LatLng(23.8350, 90.3800)),
  MetroStation(name: 'Kazipara', position: LatLng(23.8280, 90.3780)),
  MetroStation(name: 'Shewrapara', position: LatLng(23.8200, 90.3750)),
  MetroStation(name: 'Agargaon', position: LatLng(23.8120, 90.3730)),
  MetroStation(name: 'Bijoy Sarani', position: LatLng(23.7980, 90.3880)),
  MetroStation(name: 'Farmgate', position: LatLng(23.7561, 90.3872)),
  MetroStation(name: 'Karwan Bazar', position: LatLng(23.7470, 90.3950)),
  MetroStation(name: 'Shahbag', position: LatLng(23.7380, 90.3950)),
  MetroStation(name: 'Dhaka University', position: LatLng(23.7250, 90.3950)),
  MetroStation(name: 'Bangladesh Secretariat', position: LatLng(23.7300, 90.3950)),
  MetroStation(name: 'Motijheel', position: LatLng(23.7230, 90.4170)),
  MetroStation(name: 'Kamalapur', position: LatLng(23.7180, 90.4250)),
];

MetroStation? metroStationByName(String name) {
  for (final station in dhakaMetroStations) {
    if (station.name == name) return station;
  }
  return null;
}

List<String> get metroStationNames =>
    dhakaMetroStations.map((s) => s.name).toList();

/// Polyline along the metro corridor (station-to-station).
List<LatLng> get metroLineCoordinates =>
    dhakaMetroStations.map((s) => s.position).toList();
