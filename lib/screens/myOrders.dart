import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/orderDetails.dart';
import 'package:littardo/screens/order_review.dart';
import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrders createState() => _MyOrders();
}

class _MyOrders extends State<MyOrders> {
  String accessToken = "";
  Map userData;
  List orderListData = new List();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController review = new TextEditingController();
  double ratingValue = 0;

  bool showSuccess = false;

  bool serviceCalled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "My Orders",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Ionicons.getIconData("ios-arrow-back"),
                color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
        ),
        body: orderListData.length > 0
            ? SingleChildScrollView(
                child: Column(
                    children: orderListData.map((item) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => OrderDetais(item)))
                          .then((onVal) {
                        if (onVal == "success") {
                          getMyOrders();
                        }
                      });
                    },
                    child: Card(
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
                                                                item['product']
                                                                    ['name'],
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
                                                          "Ordered on - " +
                                                              item['order'][
                                                                  'created_at'],
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
                                                        child: Text(
                                                          item['delivery_status'] ==
                                                                  "0"
                                                              ? "Expected\nDelivery Date - " +
                                                                  item['order']
                                                                      ['d_date']
                                                              : item['delivery_status'] !=
                                                                          "0" &&
                                                                      item['cancel_reason'] ==
                                                                          null
                                                                  ? "Delivered on - " +
                                                                      item[
                                                                          'u_date']
                                                                  : "Cancelled on - " +
                                                                      item[
                                                                          'u_date'],
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
                                                                  'product']
                                                              ['thumbnail_img'],
                                                          height: 120,
                                                          width: 100,
                                                          fit: BoxFit.fill)))),
                                        ],
                                      ),
                                    ),
                                    item['delivery_status'] == "delivered"
                                        ? Divider()
                                        : SizedBox(),
                                    item['delivery_status'] == "delivered"
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Row(
                                              children: <Widget>[
                                                item['product']['user_review'] !=
                                                            null &&
                                                        item['product'][
                                                                    'user_review']
                                                                .length >
                                                            0
                                                    ? RatingBar(
                                                        initialRating: double
                                                            .parse(item['product']
                                                                        [
                                                                        'user_review']
                                                                    ['rating']
                                                                .toString()),
                                                        minRating: 0.5,
                                                        itemSize: 20,
                                                        direction:
                                                            Axis.horizontal,
                                                        ignoreGestures: true,
                                                        allowHalfRating: false,
                                                        itemCount: 5,
                                                        itemPadding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    4.0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                Icon(
                                                          Icons.star,
                                                          color:
                                                              Colors.blue[900],
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          print(rating);
                                                        },
                                                      )
                                                    : RatingBar(
                                                        initialRating: 0,
                                                        minRating: 0.5,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: false,
                                                        itemCount: 5,
                                                        itemPadding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    4.0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                Icon(
                                                          Icons.star,
                                                          color:
                                                              Colors.blue[900],
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Review(
                                                                          item,
                                                                          rating)))
                                                              .then((onVal) {
                                                            setState(() {
                                                              orderListData =
                                                                  new List();
                                                            });
                                                            getMyOrders();
                                                          });
                                                        },
                                                      ),
                                              ],
                                            ))
                                        : SizedBox(),
                                    item['delivery_status'] == "delivered"
                                        ? SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox()
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()),
              )
            : serviceCalled
                ? Center(
                    child: Image.asset("assets/norecordfound.png"),
                  )
                : SizedBox());
  }

  void getMyOrders() {
    getProgressDialog(context, "Fetching orders...").show();
    commeonMethod2(api_url + "orders",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          orderListData = data['orders'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching orders...").hide(context);
    });
  }
}
