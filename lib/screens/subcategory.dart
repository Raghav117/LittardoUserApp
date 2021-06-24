import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/ionicons.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/products_list.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/constant.dart';
import 'package:provider/provider.dart';

class SubCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  SubCategoryPage({
    this.categoryId,
    this.categoryName,
  });

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  List reportList = List();
  List subreportList = List();
  List brandList = List();
  PageController _pageController;
  int index = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0, keepPage: true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getSubCategory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            index == 0 ? "Sub Category List" : "Sub Sub Category List",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Ionicons.getIconData("ios-arrow-back"),
                color: Colors.black),
            onPressed: () {
              if (_pageController.page == 0) {
                Navigator.pop(context);
              } else {
                _pageController.previousPage(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeIn);
                setState(() {
                  index = 0;
                });
              }
            },
          ),
          backgroundColor: Colors.white,
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            buildCategoryList(reportList, "Sub"),
            buildCategoryList(subreportList + brandList, "Sub Sub"),
          ],
        ));
  }

  Widget buildCategoryList(List categoryList, String category) {
    return Container(
      padding: EdgeInsets.only(
        top: 45.0,
        left: 24.0,
        right: 24.0,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: categoryList.length,
        itemBuilder: (context, pos) {
          return InkWell(
            onTap: () {
              if (category == "Sub") {
                getSubSubCategory(categoryList[pos]["category_id"])
                    .then((value) {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn);
                }).then((value) {
                  setState(() {
                    index = 1;
                  });
                });
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                        id: categoryList[pos]["id"].toString(),
                        name: categoryList[pos]["name"],
                        type:
                            pos > (subreportList.length - 1) ? "brand" : "cat",
                        query: ""),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    height: 148,
                    child: new ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                gradient: LinearGradient(
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    colors: [
                                      Colors.black26,
                                      Colors.black26,
                                    ],
                                    stops: [
                                      0.0,
                                      1.0
                                    ])),
                          ),
                          Center(
                            child: Text(
                              categoryList[pos]["name"],
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )),
                pos == (subreportList.length - 1) && (category != "Sub")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Brand List",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  void getSubCategory() {
    setState(() {
      getProgressDialog(context, "Fetching sub category").show();
    });
    print(api_url + "sub-categories?category_id=" + widget.categoryId);
    commeonMethod2(api_url + "sub-categories?category_id=" + widget.categoryId,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
      Map data = json.decode(onResponse.body);
      // print(data);
      if (data['code'] == 200) {
        setState(() {
          reportList = data['sub_categories'];
          print(reportList);
        });
      } else {
        presentToast(data['message'], context, 0);
      }
    }).catchError((onerr) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
    });
  }

  Future<void> getSubSubCategory(String categoryId) async {
    setState(() {
      getProgressDialog(context, "Fetching sub sub category").show();
    });
    print(api_url + "sub-sub-categories?sub_category_id=" + categoryId);
    commeonMethod2(api_url + "sub-sub-categories?sub_category_id=" + categoryId,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          subreportList = data['sub_sub_categories'];
          brandList = data['brands'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
    }).catchError((onerr) {
      setState(() {
        getProgressDialog(context, "").hide(context);
      });
    });
  }
}
