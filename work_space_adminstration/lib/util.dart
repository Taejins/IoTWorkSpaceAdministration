import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';



var stateLatLon = {
  "state1":{//진리 37.582940905011746, 127.00948877007335
    "lat": "37.582940905011746",
    "lon": "127.00948877007335"
  },
  "state2":{//우촌 미래 37.58273259850769, 127.01076013713853
    "lat": "37.58273259850769",
    "lon": "127.01076013713853"
  },
  "state3":{//연구 지선 공학 37.58180584007381, 127.009815999573
    "lat": "37.58180584007381",
    "lon": "127.009815999573"
  },
  "state4":{//창의 인성 낙산 37.58192062270687, 127.01088888316994
    "lat": "37.58192062270687",
    "lon": "127.01088888316994"
  }
};

String selState(String lat, String lon) {
  var d_lat = double.parse(lat);
  var d_lon = double.parse(lon);

  if (37.58248184103989 < d_lat && d_lat < 37.58352762232812) {
    if (127.00888359137718 < d_lon && d_lon < 127.01008522100578)
      return "state1";
    else if (127.01008522100578 < d_lon && d_lon < 127.01153261332581)
      return "state2";
    else return "Out";
  }else if(37.58169530849158 < d_lat && d_lat < 37.58248184103989){
    if (127.00888359137718 < d_lon && d_lon < 127.01008522100578)
      return "state3";
    else if (127.01008522100578 < d_lon && d_lon < 127.01153261332581)
      return "state4";
    else return "Out";
  }
  else return "Out";
}
String TimeStampFormat(String ts){
  var dt_ts = new DateTime.fromMillisecondsSinceEpoch(int.parse(ts)*1000);
  return DateFormat('yy-MM-dd HH:mm').format(dt_ts);
}
LatLng strToLatLng(String lat, String lon){
  var _lat = double.parse(lat);
  var _lon = double.parse(lon);
  return LatLng(_lat,_lon);
}
class rowText extends StatelessWidget {
  final String st1;
  final String st2;
  final double size;
  final int boldSection;

  const rowText({Key? key, required this.st1, required this.st2, required this.size, required this.boldSection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          st1,
          style: TextStyle(fontSize: size, fontWeight: boldSection==1 ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          st2,
          style: TextStyle(
              fontSize: size, fontWeight: boldSection==2 ? FontWeight.bold : FontWeight.normal),
        )
      ],
    );
  }
}
