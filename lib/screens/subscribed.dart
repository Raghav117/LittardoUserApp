import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:littardo/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:provider/provider.dart';


class SubscribedPackage extends StatefulWidget{
  _SubscribedPackage createState()=> _SubscribedPackage();
}

class _SubscribedPackage extends State<SubscribedPackage>{
  String accessToken = "";
  List subscribedListData = [];
  bool serviceCalled = false;
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSavedData();
  }

  Future<void> checkSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");
    fetchSubscribed();
  }
fetchSubscribed(){
  getProgressDialog(context, "Fetching packages...").show();
    commeonMethod2(api_url + "subscribed-packages",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          subscribedListData = data['data'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching packages...").hide(context);
    });
}
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            elevation: 0,
              leading: IconButton(
            icon: Icon(Ionicons.getIconData("ios-arrow-back"),
                color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
            backgroundColor: Colors.white,
            title: Text(
              "Subscribed Packages",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body:subscribedListData.length > 0
            ? SingleChildScrollView(child: Column(children: subscribedListData.map((item) {
                  return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey[300],
                        child: Column(
                          children: <Widget>[
                            Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 8,
                                            child: Row(
                                              children: <Widget>[
                                                Container(
//                                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  width: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow[900],
//                                            border: Border(
//                                                bottom: BorderSide(width: 1.0, color: Color(0xffABA6A6)),
//                                                right: BorderSide(width: 1.0, color: Color(0xffABA6A6)))
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        child: Wrap(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 3,
                                                                      top: 10,
                                                                      bottom:
                                                                          10,
                                                                      right: 3),
                                                              child: Text(
                                                                item['subscription_category_name'],
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 3,
                                                                bottom: 10),
                                                        child: Text(
                                                          "Subscribed on - " +
                                                              item['created_at'],
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 3,
                                                                bottom: 10),
                                                        child: Text("Package - " +
                                                                  item['package_title'],
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 3,
                                                                bottom: 10),
                                                        child: Text("Amount - " +
                                                                  item['package_amount'],
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  6,
                                              child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: ClipRRect(
                                                      child: CachedNetworkImage(
                                                          imageUrl: item[
                                                                  'subscription_category_image'],
                                                          height: 120,
                                                          width: 100,
                                                          fit: BoxFit.fill)))),
                                        ],
                                      ),
                                    ),
                                   
                                    
                                  ],
                                )),
                          ],
                        ),
                      ));}).toList()),): serviceCalled
                ? Center(
                    child: Image.asset("assets/norecordfound.png"),
                  )
                : SizedBox())]);
  }
}