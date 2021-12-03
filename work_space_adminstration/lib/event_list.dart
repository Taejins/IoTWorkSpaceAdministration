import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:work_space_adminstration/event_info.dart';
import 'util.dart';


class Event_list extends StatefulWidget {
  const Event_list({Key? key}) : super(key: key);

  @override
  State<Event_list> createState() => _Event_listState();
}

class _Event_listState extends State<Event_list> {
  TextEditingController title_cn = TextEditingController();
  TextEditingController supp_cn = TextEditingController();


  var _selState = "state1";
  List<String> stateList = ["state1","state2","state3","state4"];

  List<dynamic> event = [
    // {
    //   "id": "1",
    //   "title": "emergency event",
    //   "lat": "1",
    //   "lon": "1",
    //   "support": "99",
    //   "time": "1638253964",
    //   "valid": "2"
    // },
  ];

  @override
  void initState() {
    super.initState();
    _getEvent();
  }




  _getEvent() async {
    var url = Uri.parse(
        "api1");
    var response = await http.get(url);
    var statusCode = response.statusCode;

    List<dynamic> list = [];
    if (statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      list = jsonDecode(responseBody);
      list.sort((a, b) => (int.parse(b['time'])).compareTo(int.parse(a['time'])));
    }
    setState(() {
      event = list;
    });
  }

  Future _putEvent(String title, String support, String state) async {
    var url = Uri.parse(
        "api2");
    var response = await http.post(url);
    var statusCode = response.statusCode;

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('작업이 생성되었습니다.')));
    }
  }

  Future _modEvent(String id, String valid, String title, String time) async {
    var toValid;
    if (valid !='0') toValid = '0';
    else if(title == "Urgent Support Request") toValid = '2';
    else toValid = '1';
    var url = Uri.parse(
        "api3");
    var response = await http.post(url);
    var statusCode = response.statusCode;

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('작업이 변경되었습니다.')));
    }
  }

  Future _delEvent(String id, String time) async {
    var url = Uri.parse(
        "api4");
    var response = await http.delete(url);
    var statusCode = response.statusCode;

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('작업이 삭제되었습니다.')));
    }
  }
  void dispose(){
    title_cn.dispose();
    supp_cn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                      actions: [
                        TextButton(
                            onPressed: () async {
                              await _putEvent(title_cn.text,supp_cn.text,_selState);
                              Navigator.of(context).pop(context);
                              _getEvent();
                            },
                            child: Text('생성')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('취소'))
                      ],
                      title: Text('작업 생성'),
                      content: SingleChildScrollView(
                        child: Container(
                          width: 400,
                          child: Column(
                            children: [
                              TextField(
                                controller: title_cn,
                                decoration: InputDecoration(labelText: "작업 이름"),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Text('장소 : '),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        DropdownButton(
                                          value: _selState,
                                          items: stateList.map((value) {
                                            return DropdownMenuItem(
                                                value: value, child: Text(value));
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selState = value.toString();
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ),

                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: supp_cn,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          InputDecoration(labelText: "인원"),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child:SizedBox()
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );}
                );
              }
              );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("작업 현황"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getEvent();
            },
          )
        ],
      ),
      body: ListView.separated(
          itemCount: event.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onLongPress: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      await _delEvent(event[index]['id'],event[index]['time']);
                                      Navigator.of(context).pop();
                                      _getEvent();
                                    },
                                    child: Text('작업 삭제')),
                                TextButton(
                                    onPressed: () async{
                                      await _modEvent(event[index]['id'], event[index]['valid'], event[index]['title'],event[index]['time']);
                                      Navigator.of(context).pop();
                                      _getEvent();
                                    },
                                    child: Text('확인')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('취소'))
                              ],
                              title: event[index]['valid'] == '0' ? Text('작업을 재개하시겠습니까?') : Text('작업을 끝내시겠습니까?'),
                              content: SingleChildScrollView(
                                child: Container(

                                ),
                              ),
                            );
                          });
                    }
                );
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => event_info(
                              id: event[index]['id'],
                              title: event[index]['title'],
                              lat: event[index]['lat'],
                              lon: event[index]['lon'],
                              state: selState(
                                  event[index]['lat'], event[index]['lon']),
                              time: event[index]['time'],
                              support: event[index]['support'],
                              valid: event[index]['valid'],
                            )));
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                height: 100,
                decoration: BoxDecoration(
                    color: event[index]['valid'] == '1'
                        ? Colors.lightGreenAccent
                        : event[index]['valid'] == '2'
                            ? Colors.redAccent
                            : Colors.grey,
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${event[index]['title']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('발생 시간 : ${TimeStampFormat(event[index]['time'])}',
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '위치 : ${selState(event[index]['lat'], event[index]['lon'])}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '지원 요청 인력 : ${event[index]['support']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

