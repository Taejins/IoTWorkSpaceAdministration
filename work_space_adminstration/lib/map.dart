import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:work_space_adminstration/util.dart';

import 'event_list.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
      target: LatLng(37.582345803468556, 127.00945758457985), zoom: 18.0);
  TextEditingController _tokenCn = TextEditingController();
  GoogleMapController? _googleMapController;
  List<Marker> _markers = [];
  List<dynamic> dvLoc = [
    // {
    //   "deviceid": "emploefeyees1",
    //   "time": "1638285672",
    //   "lat": "37.5818181920572",
    //   "lon": "127.00985049333"
    // },
    // {
    //   "deviceid": "emplaweoyees3",
    //   "time": "1638285691",
    //   "lat": "37.5829618839776",
    //   "lon": "127.00957170875282"
    // },
    // {
    //   "deviceid": "emplfdfoyees2",
    //   "time": "1638285683",
    //   "lat": "37.58219322155263",
    //   "lon": "127.01129012426628"
    // }
  ];

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) {
      print(token);
      _tokenCn.text = token!;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var msg = jsonDecode(message.data['default']);
      showSnackBar(msg['urgent'],msg['deviceid']);
    });
    _getDV();
  }

  void showSnackBar(String urgent, String deviceid){
    if (urgent=='1'){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('[${deviceid}] 사용자가 긴급 지원 요청하였습니다.'),
      backgroundColor: Colors.red,));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('[${deviceid}] 사용자가 수신 응답하였습니다.'),));
    }

  }

  _getDV() async {
    var url = Uri.parse(
        "api1");
    var response = await http.get(url);
    var statusCode = response.statusCode;

    List<dynamic> list = [];
    if (statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      list = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('위치를 요청합니다.'),));
    }
    setState(() {
      dvLoc = list;
      for(int i=0;i<dvLoc.length;i++){
        _addMarker(strToLatLng(dvLoc[i]['lat'], dvLoc[i]['lon']) , dvLoc[i]['deviceid']);
      }
    });
  }


  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: Icon(Icons.menu),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Event_list()));
        },
      ),
      appBar: AppBar(
        title: Text('근로자 위치 파악'),
        centerTitle: true,
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context)
              {
                return AlertDialog(
                  content: TextField(
                    controller: _tokenCn,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('취소')),
                  ],
                );
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getDV();
            },
          ),
        ],
      ),
      body: GoogleMap(
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (controller) => _googleMapController = controller,
          markers: Set.from(_markers)
          ),
    );
  }

  Future _addMarker(LatLng pos,String id) async{
    _markers.add(Marker(
      markerId: MarkerId(id),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title:id),
      position: pos,
    ));
  }
}

