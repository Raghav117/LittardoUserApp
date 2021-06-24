import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:littardo/screens/subscription.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class SubCategory extends StatefulWidget {

  @override
  _SubCategory createState() => _SubCategory();
}

class _SubCategory extends State<SubCategory> {
  bool _isLoading = false;
  List subCategoryData = new List();
  String accessToken = "";
  bool serviceCalled = false;
  String category_id;
  String category_name;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSavedData();
  }

  Future<void> checkSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");
    fetchSubCategory();
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
              "Subscription Categories",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
            ),
            itemCount: subCategoryData.length,
            itemBuilder: (BuildContext contex, int index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => new SubscriptionPlans(
                          subCategoryData[index]['id'].toString(),
                          subCategoryData[index]['name'])));
                },
                child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
//                                  decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.only(topLeft:Radius.circular(10),topRight:  Radius.circular(10)),
//                                  ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                child: CachedNetworkImage(
                                    imageUrl: subCategoryData[index]['image'],
                                    fit: BoxFit.fill))),
                        Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5)),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: new Text(
                                    subCategoryData[index]['name'],
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                    textAlign: TextAlign.center, // has impact
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
              );
            },
          ),
        )
      ],
    );
  }


  void fetchSubCategory() {
    getProgressDialog(context, "Please wait...").show();
    commeonMethod2(api_url + "subscription-categories",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        setState(() {
          subCategoryData = data['data'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Please wait...").hide(context);
    });
  }
}
