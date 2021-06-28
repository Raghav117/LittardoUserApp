import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/widgets/submitbutton.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class OrderDetais extends StatefulWidget {
  Map product;

  OrderDetais(Map product) {
    this.product = product;
  }

  @override
  _OrderDetais createState() => _OrderDetais(product);
}

class _OrderDetais extends State<OrderDetais> {
  Map product;
  String showReview = "";
  List tracking = new List();
  bool is_returnable = false;
  TextEditingController reason = new TextEditingController();

  _OrderDetais(Map product) {
    this.product = product;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getOrderDetails();
    });
  }

  void submitReturn(String reasonText) {
    getProgressDialog(context, "Return Request...").show();
    print(api_url + "orders/returns");
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "orders/return"));
    request.fields["order_details_id"] = product['id'].toString();
    request.fields["order_id"] = product['order_id'].toString();
    request.fields["product_id"] = product['product_id'].toString();
    request.fields["seller_id"] = product['seller_id'].toString();
    request.fields["reason"] = reasonText;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/json";
    request.headers["APP"] = "ECOM";
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
         getOrderDetails();
         Navigator.pop(context);
        }
        getProgressDialog(context, "Return Request...").hide(context);
      });
    });
  }

  getOrderDetails() {
    getProgressDialog(context, "Fetching order Details...").show();
    commeonMethod2(api_url + "orders/${widget.product["id"]}",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          is_returnable = data['is_returnable'];
          product = data['order'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      getProgressDialog(context, "Fetching order Details...").hide(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, showReview);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {Navigator.pop(context, showReview)}),
          title: Text(
            "Order Detail",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/pattern.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          new Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: new RichText(
                                  text: TextSpan(
                                      text: "Order ID - ",
                                      style: TextStyle(
                                          color: Colors.grey.withOpacity(0.9),
                                          fontSize: 12),
                                      children: [
                                    TextSpan(
                                        text: product['order']['code'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ))
                                  ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
//                                            Navigator.of(context).push(
//                                                new MaterialPageRoute(
//                                                    builder: (context) =>
//                                                    new ProductDetails(
//                                                        product['order_details'][0]
//                                                        ['product'])));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(3.0),
                                              child: Text(
                                                product['product']['name'],
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                "Ordered On - " +
                                                    product['created_at'],
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
//                                          Navigator.of(context).push(
//                                              new MaterialPageRoute(
//                                                  builder: (context) =>
//                                                  new ProductDetails(
//                                                      product['order_details'][0]
//                                                      ['product'])));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                                child: CachedNetworkImage(
                                              imageUrl: product['product']
                                                  ['thumbnail_img'],
                                              height: 120,
                                              width: 100,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      new CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      new Icon(
                                                Icons.error,
                                                size: 100,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Text(
                                        "Description -  " +
                                            product['product']['description'],
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Text(
                                        "Seller: Littardo Emporium",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                    is_returnable
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: FlatButton(
                                              shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0),
                                              ),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              onPressed: () {
                                                return showCupertinoModalPopup(
                context: context, builder: (context) => CupertinoActionSheet(
              title: Text("Choose Reason"),
              message: Text("Select any reason "),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Wrong item was sent",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("Wrong item was sent");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Performance or Quality of the product not adequate",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("Performance or Quality of the product not adequate");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("The item is damaged but the box or envelope in which it has been packed is undamaged",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("The item is damaged but the box or envelope in which it has been packed is undamaged");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Item defective or doesn’t work",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("Item defective or doesn’t work");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("The item and the box or envelope it came in are both damaged",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("The item and the box or envelope it came in are both damaged");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Different from what was ordered",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("Different from what was ordered");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Any orders item is missing",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDefaultAction: true,
                  onPressed: () {
                    submitReturn("Any orders item is missing");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Others",style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                  isDestructiveAction: true,
                  onPressed: () {
                    showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                  "Return"),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          TextField(
                                                                        autofocus:
                                                                            true,
                                                                        controller:
                                                                            reason,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        decoration: InputDecoration(
                                                                            counterStyle: TextStyle(
                                                                              height: double.minPositive,
                                                                            ),
                                                                            counterText: "",
                                                                            labelText: "Enter Reason",
                                                                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                                                            border: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              borderSide: BorderSide(),
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text(
                                                                      "Submit",style: TextStyle(color: Theme
                                                                      .of(context).primaryColor),),
                                                                  onPressed:
                                                                      () {
                                                                    if (reason
                                                                            .text
                                                                            .length <
                                                                        1) {
                                                                      presentToast(
                                                                          "Enter reason",
                                                                          context,
                                                                          2);
                                                                    } else {
                                                                      Navigator.pop(
                                                                          context,
                                                                          false);
                                                                      submitReturn(reason.text);
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            )).then((value) => setState((){reason.clear();}));
                  },
                )
              ],
));
                                                
                                              },
                                              child: new Container(
                                                width: 60,
                                                height: 30,
                                                child: new Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    new Expanded(
                                                      child: Text(
                                                        "Return",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: IntrinsicHeight(
                          child: Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: tracking.map((item) {
                              return Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      new Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              28,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                          )),
                                      Wrap(
                                        direction: Axis.vertical,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 10, right: 10),
                                            child: new Text(
                                              item['comment'],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                decoration: TextDecoration.none,
                                              ),
                                              textAlign:
                                                  TextAlign.start, // has impact
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: new Text(
                                              item['created_at'],
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8,
                                                decoration: TextDecoration.none,
                                              ),
                                              textAlign:
                                                  TextAlign.start, // has impact
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  VerticalDivider(
                                    thickness: 1,
                                    color: Colors.blue,
                                    endIndent: 10,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ))),
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Divider()),
//                                Padding(
//                                    padding: EdgeInsets.only(
//                                        left: 10, right: 10),
//                                    child: Row(
//                                      children: <Widget>[
//                                        RatingBar(
//                                          initialRating: product['order_details'][0]['review']
//                                              .length > 0 ? double.parse(
//                                              product['order_details']
//                                              [0]['review']['rating']
//                                                  .toString()) : 0,
//                                          minRating: 0.5,
//                                          itemSize: 15,
//                                          direction: Axis.horizontal,
//                                          ignoreGestures: true,
//                                          allowHalfRating: false,
//                                          itemCount: 5,
//                                          itemPadding:
//                                          EdgeInsets.symmetric(horizontal: 2.0),
//                                          itemBuilder: (context, _) =>
//                                              Icon(
//                                                Icons.star,
//                                                color: Colors.blue[900],
//                                              ),
//                                          onRatingUpdate: (rating) {
//                                            print(rating);
//                                          },
//                                        ),
//                                        Spacer(),
//                                        (showReview != "success")
//                                            ? InkWell(
//                                          onTap: () {
////                                            Navigator.of(context)
////                                                .push(MaterialPageRoute(
////                                                builder: (context) =>
////                                                    Review(product)))
////                                                .then((onVal) {
////                                              if (onVal == "success") {
////                                                setState(() {
////                                                  showReview = onVal;
////                                                });
////                                              }
////                                            });
//                                          },
//                                          child: Text(
//                                            "WRITE A REVIEW",
//                                            style: TextStyle(
//                                                color: Colors.blue[900],
//                                                fontSize: 10),
//                                          ),
//                                        )
//                                            : SizedBox(),
//                                      ],
//                                    )),
                ],
              ),

//                        Container(
//                          color: Colors.white,
//                          child: Padding(
//                            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
//                            child: Row(
//                              children: <Widget>[
//                                IconButton(
//                                    icon: new Icon(Icons.insert_drive_file,
//                                        color: Colors.black),
//                                    onPressed: () {
//
//                                    }),
//                                SizedBox(
//                                  width: 5,
//                                ),
//                                Text("EMAIL INVOICE",
//                                    style: TextStyle(
//                                        color: Colors.grey, fontSize: 12)),
//                              ],
//                            ),
//                          ),
//                        ),
//                        SizedBox(
//                          height: 8,
//                        ),
              Card(
                  child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      new Flexible(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 10, right: 10),
                          child: new Text(
                            "Shipping Address",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center, // has impact
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Divider(
                        thickness: 1,
                      )),
                  Row(
                    children: <Widget>[
                      new Flexible(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 10, right: 10),
                          child: new Text(
                            product['order']['shipping_address']['name'],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center, // has impact
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      new Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10, top: 10, bottom: 10, right: 10),
                          child: new Text(
                            product['order']['shipping_address']['address'] +
                                ", " +
                                product['order']['shipping_address']['city'] +
                                ", " +
                                product['order']['shipping_address']
                                    ['country'] +
                                ", PIN - " +
                                product['order']['shipping_address']
                                    ['postal_code'],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center, // has impact
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
              SizedBox(
                height: 8,
              ),
              priceSection()
            ],
          ))),
        ),
      ),
    );
  }

  priceSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Text(
                "PRICE DETAILS",
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              createPriceItem(
                  "List Price",
                  "\u20b9 ${double.parse(product['order']['grand_total'])}",
                  Colors.grey.shade700),
              createPriceItem(
                  "Extra Discount",
                  "\u20b9 ${double.parse(product['order']['coupon_discount'])}",
                  Colors.red.shade300),
              createPriceItem(
                  "Shipping Fee",
                  "\u20b9 ${double.parse(product['shipping_cost'])}",
                  Colors.grey.shade700),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    "\u20b9 ${double.parse(product['order']['grand_total'])}",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment Mode",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      product['payment_type'] != "cash_on_delivery"
                          ? 'Online Payment'
                          : "Cash on Delivery",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment Status",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      product['payment_status'],
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  createPriceItem(String key, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            color == Colors.red.shade300 ? "- " + value : value,
            style: TextStyle(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }
}
