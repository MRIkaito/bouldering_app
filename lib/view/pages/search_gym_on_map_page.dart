import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchGymOnMapPage extends StatefulWidget {
  const SearchGymOnMapPage({super.key});

  @override
  State<SearchGymOnMapPage> createState() => _SearchGymOnMapPageState();
}

class _SearchGymOnMapPageState extends State<SearchGymOnMapPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(35.681236, 139.767125); // 東京駅など適当な場所に

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地図からジムを探す'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }
}
