import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:littardo/provider/UserData.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notifications = new List();
  bool serviceCalled = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Notifications",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: notifications.length > 0
          ? ListView.builder(
              itemBuilder: (context, index) {
                return createNotificationListItem(index);
              },
              itemCount: notifications.length,
            )
          : serviceCalled
              ? Center(
                  child: Image.asset("assets/norecordfound.png"),
                )
              : SizedBox(),
    );
  }

  getNotifications() {
    getProgressDialog(context, "Fetching notifications...").show();
    commeonMethod2(api_url + "notifications",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          notifications = data['data'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching address...").hide(context);
    }).catchError((onerr) {
      getProgressDialog(context, "Fetching address...").hide(context);
    });
  }

  void deleteNotification(String id) {
    getProgressDialog(context, "Deleting notification...").show();
    commeonMethod2(api_url + "notifications/delete?id=$id",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      print(data);
      presentToast(data['message'], context, 0);
      if (data['code'] == 200) {
        getNotifications();
      }
      getProgressDialog(context, "Deleting address...").hide(context);
    });
  }
  /*createItem(){
    return ListTile(
      title: Text(
        "Payment Complete",
        style: CustomTextStyle.textFormFieldBlack
            .copyWith(color: Colors.black, fontSize: 16),
      ),
      isThreeLine: true,
      trailing: IconButton(icon: Icon(Icons.close), onPressed: () {}),
      subtitle: Text(
        "Thank you for your recent payment. Your monthly subscription has been activated until June 2020.",
        softWrap: true,
        style: CustomTextStyle.textFormFieldMedium
            .copyWith(color: Colors.grey,fontSize: 14),
      ),
    );
  }*/

  createNotificationListItem(int index) {
    return Dismissible(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                width: 4,
                margin: EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  color: Colors.green,
                ),
              ),
              flex: 02,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        notifications[index]['title'],
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                          icon: Icon(Icons.close,color: Theme.of(context).primaryColor,),
                          onPressed: () {
                            deleteNotification(
                                notifications[index]['id'].toString());
                          })
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 6),
                    child: Text(
                      notifications[index]['body'],
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                ],
              ),
              flex: 98,
            )
          ],
        ),
      ),
      key: Key("key_1" + notifications[index]['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
        deleteNotification(notifications[index]['id'].toString());
      },
      background: Container(
        color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
