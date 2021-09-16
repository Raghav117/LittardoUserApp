import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:littardo/provider/UserData.dart';
import 'personalChat.dart';

class Chats extends StatefulWidget {
  const Chats({Key key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  TextEditingController message = TextEditingController();
  TextEditingController subject = TextEditingController();

  void fetchData() async {
    print(Provider.of<UserData>(context, listen: false).userData['api_token']);
    var response = await commeonMethod2(
        "https://chat.littardoemporium.com/api/chats/",
        Provider.of<UserData>(context, listen: false).userData['api_token']);
    names = jsonDecode(response.body)['chats'] == null
        ? []
        : jsonDecode(response.body)['chats'];
    setState(() {
      loading = false;
    });
  }

  List names = [];
  @override
  void initState() {
    fetchData();

    super.initState();
  }

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var response = await showDialog(
                  context: context,
                  child: Dialog(
                    child: Container(
                      height: 400,
                      width: 600,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Text(
                              "New Chat",
                              style: TextStyle(fontSize: 20),
                            )),
                            SizedBox(
                              height: 60,
                            ),
                            Text("Subject"),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: subject,
                                    decoration: InputDecoration(
                                        hintText: "Enter Subject",
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text("Message"),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: message,
                                    decoration: InputDecoration(
                                        hintText: "Enter Message",
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Center(
                              child: InkWell(
                                onTap: () {
                                  if (subject.text.length > 0 &&
                                      message.text.length > 0)
                                    Navigator.pop(context, true);
                                },
                                child: Container(
                                  color: Color(0xFFf3b656),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Start"),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
              if (response == true) {
                setState(() {
                  loading = true;
                });
                var result = await commeonMethod9(
                    "https://chat.littardoemporium.com/api/init-chat",
                    {"message": message.text, "subject": subject.text},
                    Provider.of<UserData>(context, listen: false)
                        .userData['api_token'],
                    context);
                Map m = jsonDecode(result.body);
                print(m);

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return PersonalChat(
                    subject: m["subject"],
                    chatId: m["chat_id"],
                  );
                })).whenComplete(() {
                  fetchData();
                });
                message.clear();
                subject.clear();
              }
            },
          )
        ],
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
              children: List.generate(names.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return PersonalChat(
                          subject: names[index]["subject"],
                          chatId: names[index]["chat_id"],
                        );
                      }));
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      child: Row(
                        children: [
                          // Icon(
                          //   Icons.face,
                          //   size: 30,
                          //   color: Color(0xFFf3b656),
                          // ),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                "assets/speak.png",
                                width: 40,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                names[index]["reference_id"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                names[index]["subject"],
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(names[index]["created_at"])
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )),
    );
  }
}
