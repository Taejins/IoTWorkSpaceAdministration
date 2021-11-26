import 'package:flutter/material.dart';

class Event_list extends StatefulWidget {
  const Event_list({Key? key}) : super(key: key);

  @override
  State<Event_list> createState() => _Event_listState();
}

class _Event_listState extends State<Event_list> {
  List<dynamic> questions = [
    "안녕하세요 질문입니다",
    "안녕하세요 질문입니다 안녕하세요 질문입니다",
    "안녕하세요 질문입니다",
    "안녕하세요 질문입니다",
    "안녕하세요 질문입니다",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 ",
    "안녕하세요 질문입니다 "
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Page"),
      ),
      body: ListView.separated(
        itemCount: questions.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index){
              return GestureDetector(
                onTap: (){print('$index taped');},
                child: Container(
                  height: 50,
                  child: Column(
                    children: [
                      Text('Entry ${questions[index]}'),
                      Text('Entry ${questions[index]}'),
                    ],
                  ),
                ),
              );
            }
        ),
    );
  }
}
