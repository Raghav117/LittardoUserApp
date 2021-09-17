import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:littardo/provider/UserData.dart';
import 'personalChat.dart';

class PersonalChat extends StatefulWidget {
  final int chatId;
  final String subject;
  const PersonalChat({Key key, this.chatId, this.subject}) : super(key: key);

  @override
  _PersonalChatState createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  void fetchData({bool isMessage = false}) async {
    if (isMessage == false) {
      print(
          Provider.of<UserData>(context, listen: false).userData['api_token']);
      var response = await commeonMethod2(
          "https://chat.littardoemporium.com/api/chats/${widget.chatId}",
          Provider.of<UserData>(context, listen: false).userData['api_token']);
      print(response);
      print(jsonDecode(response.body));
      chats = jsonDecode(response.body)['chats'];
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      var response = await commeonMethod9(
          "https://chat.littardoemporium.com/api/chats/${widget.chatId}",
          {"message": message.text},
          Provider.of<UserData>(context, listen: false).userData['api_token'],
          context);
      print(response);
      print(jsonDecode(response.body));
      chats = jsonDecode(response.body)['chats'];
      setState(() {
        isLoading = false;
        message.text = "";
      });
    }
    if (chats.length > 20)
      controller.jumpTo(controller.position.maxScrollExtent);
  }

  bool isLoading = false;
  List chats = [];
  bool loading = true;
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  ScrollController controller = ScrollController();
  TextEditingController message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/face.png",
                  width: 40,
                )),
            Spacer(),
            Text(widget.subject),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                      child: ListView(
                    controller: controller,
                    children: chats.map((e) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: e["from"] == "user"
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(0xFFf3b656)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e["message"]),
                                ),
                              ),
                            ),
                            Align(
                                alignment: e["from"] == "user"
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(
                                  e["created_at"],
                                  style: TextStyle(fontSize: 10),
                                ))
                          ],
                        ),
                      );
                    }).toList(),
                  )),
                ),
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFFf3b656).withOpacity(0.5)),
                              child: Container(
                                constraints: BoxConstraints(minHeight: 50),
                                // height: 50,
                                width: MediaQuery.of(context).size.width - 70,
                                // width: double.infinity,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Flexible(
                                      child: TextField(
                                        controller: message,
                                        // minLines: 1,
                                        // maxLines: 12,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Type your message"),
                                        onChanged: (value) {},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              color: Color(0xFFf3b656),
                              icon: Icon(Icons.send),
                              onPressed: () {
                                if (message.text.length != 0) {
                                  fetchData(isMessage: true);
                                }
                              },
                            )
                          ],
                        ),
                      )
              ],
            ),
    );
  }
}
