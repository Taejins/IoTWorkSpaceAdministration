import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'event_list.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(37.582345803468556, 127.00945758457985), zoom: 18.0);

  GoogleMapController? _googleMapController;
  Marker? _origin;

  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.menu),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Event_list()));
        },
      ),
      appBar: AppBar(
        title: Text('근로자 위치 파악'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('refresh button');
            },
          )
        ],
      ),
      body: GoogleMap(
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (controller) => _googleMapController = controller,
          markers: {if (_origin != null) _origin!},
          onLongPress: _addMarker),
    );
  }

  void _addMarker(LatLng pos) {
    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
      );
    });
  }
}
