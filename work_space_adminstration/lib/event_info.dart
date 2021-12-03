import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'util.dart';

class event_info extends StatefulWidget {
  final String? id;
  final String? title;
  final String? lat;
  final String? lon;
  final String? state;
  final String? time;
  final String? support;
  final String? valid;

  const event_info(
      {Key? key,
      @required this.id,
      @required this.title,
      @required this.lat,
      @required this.lon,
      @required this.state,
      @required this.time,
      @required this.support,
      @required this.valid})
      : super(key: key);

  @override
  State<event_info> createState() => _event_infoState();
}

// Text('${widget.title} ${widget.lat} ${widget.lon} ${widget.state} ${widget.time} ${widget.support}')

class _event_infoState extends State<event_info> {
  List<dynamic> dv = [
    // {
    //   "deviceid": "emploefeyees1",
    //   "time": "1638285672",
    //   "lat": "123.41454",
    //   "lon": "37.23234"
    // },
  ];

  @override
  void initState() {
    super.initState();
    _getDV();
  }

  _getDV() async {
    var url = Uri.parse(
        "api5");
    var response = await http.get(url);
    var statusCode = response.statusCode;

    List<dynamic> list = [];
    if (statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      list = jsonDecode(responseBody);
      list.sort((a, b) => (int.parse(b['time'])).compareTo(int.parse(a['time'])));
    }
    setState(() {
      dv = list;
    });
  }
  Future _callDV(String dvid, String place) async {
    var url = Uri.parse(
        "api6");
    var response = await http.post(url);
    var statusCode = response.statusCode;

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('호출 신호가 전송되었습니다.')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text("Event Info"),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                color: widget.valid == '1'
                    ? Colors.lightGreenAccent
                    : widget.valid == '2'
                        ? Colors.redAccent
                        : Colors.grey,
                child: Column(
                  children: [
                    // SizedBox(width: double.infinity,),
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                            child: Text('${widget.title}',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)))),
                    SizedBox(
                      height: 20,
                    ),
                    rowText(
                        st1: '발생 시간 : ',
                        st2: '${TimeStampFormat(widget.time!)}',
                        size: 30,
                        boldSection: 2),
                    rowText(
                        st1: '위치 : ',
                        st2: '${widget.state}',
                        size: 30,
                        boldSection: 2),
                    rowText(
                        st1: '',
                        st2: '[ ${widget.lat},  ${widget.lon} ]',
                        size: 20,
                        boldSection: 2),
                    SizedBox(
                      height: 10,
                    ),
                    rowText(
                        st1: '지원 요청 인력 : ',
                        st2: '${widget.support}',
                        size: 30,
                        boldSection: 2)
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: widget.valid =="0"?Container(
                  color: Colors.grey
                ):Container(
                  margin: EdgeInsets.all(60),
                  color: Colors.white,
                  child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemCount: dv.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              print('taped ${index}');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('인원을 호출하십니까?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await _callDV(dv[index]['deviceid'],widget.state!);
                                              Navigator.of(context).pop(context);
                                              _getDV();
                                            },
                                            child: Text('호출')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('취소'))
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    border: Border.all(width: 2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                child: Column(
                                  children: [
                                    rowText(
                                        st1: dv[index]['deviceid'],
                                        st2:
                                            '${TimeStampFormat(dv[index]['time'])}',
                                        size: 25,
                                        boldSection: 1),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    rowText(
                                        st1:
                                            '${selState(dv[index]['lat'], dv[index]['lon'])}',
                                        st2:
                                            '[ ${dv[index]['lat']}, ${dv[index]['lon']} ]',
                                        size: 20,
                                        boldSection: 3)
                                  ],
                                )));
                      }),
                ))
          ],
        ));
  }
}
