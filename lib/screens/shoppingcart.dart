import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/ionicons.dart';
import 'package:http/http.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/navigator.dart';
import 'package:littardo/widgets/submitbutton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'checkout.dart';

// ignore: must_be_immutable
class ShoppingCart extends StatefulWidget {
  bool showAppBar = true;

  ShoppingCart(this.showAppBar);

  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  bool emptycart = true;
  bool serviceCalled = false;
  TextEditingController price = new TextEditingController();
  TextEditingController couponCode = TextEditingController();
  String isCash = "";
  List mycartData = new List();
  bool isLoading = false;
  double couponValue = 0.0;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getMyCartList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.showAppBar
            ? AppBar(
                centerTitle: true,
                title: Text(
                  "Shopping Cart",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                leading: IconButton(
                  icon: Icon(Ionicons.getIconData("ios-arrow-back"),
                      color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.white,
              )
            : null,
        body: mycartData.length > 0
            ? Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: mycartData.length,
                          itemBuilder: (context, index) {
                            return buildShoppingCartItem(
                                context, mycartData[index]);
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Subtotal",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text("\u20b9 " + getSubTotalPrice(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                // isCash == "Online Payment"
                                //     ? SizedBox(
                                //         height: 10.0,
                                //       )
                                //     : SizedBox(),
                                // isCash == "Online Payment"
                                //     ? Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         children: <Widget>[
                                //           Wrap(
                                //             direction: Axis.vertical,
                                //             children: <Widget>[
                                //               Text("Addition 2% discount",
                                //                   style: TextStyle(
                                //                       fontSize: 12,
                                //                       fontWeight:
                                //                           FontWeight.w600)),
                                //               Text("(Only for pre-paid orders)",
                                //                   style: TextStyle(
                                //                       fontSize: 10,
                                //                       fontStyle:
                                //                           FontStyle.italic,
                                //                       fontWeight:
                                //                           FontWeight.w600)),
                                //             ],
                                //           ),
                                //           Text(
                                //               "-" +
                                //                   (double.parse(
                                //                               getSubTotalPrice()) *
                                //                           0.02)
                                //                       .toStringAsFixed(2),
                                //               style: TextStyle(
                                //                   fontSize: 12,
                                //                   fontWeight: FontWeight.w600,
                                //                   color: Colors.red)),
                                //         ],
                                //       )
                                //     : SizedBox(),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Wallet Discount",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        "\u20b9 ${Provider.of<UserData>(context,listen: false).userData['balance']}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Shipping Charges",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        double.parse(getSubTotalPrice()) < 599
                                            ? "\u20b9 49"
                                            : "\u20b9 0",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Total",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        "\u20b9 " +
                                            "${double.parse(getTotalPrice()) - couponValue - double.parse(Provider.of<UserData>(context,listen: false).userData['balance'])}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                        flex: 1,
                                        child: Center(
                                          child: new Text(
                                            "PAYMENT MODE",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              decoration: TextDecoration.none,
                                            ),
                                            textAlign:
                                                TextAlign.left, // has impact
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Flexible(
                                                flex: 1,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // showThankYouBottomSheet(
                                                    //     context,
                                                    //     'Additional 2% discount on Online Payment');
                                                    setState(() {
                                                      isCash = "Online Payment";
                                                      price.text = "";
                                                    });
                                                  },
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: FittedBox(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          "Online Payment",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff34a953)),
                                                        ),
                                                        (isCash != null &&
                                                                isCash ==
                                                                    "Online Payment")
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color:Color(0xFF3c3790))
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 18,
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isCash =
                                                          "cash_on_delivery";
                                                    });
                                                  },
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: FittedBox(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Pay Cash",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xff34a953),
                                                          ),
                                                        ),
                                                        (isCash != null &&
                                                                isCash ==
                                                                    "cash_on_delivery")
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color:
                                                                    Color(0xFF3c3790))
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: couponCode,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.card_giftcard),
                            hintText: "Enter Coupon code",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  verifyCoupon(couponCode.text);
                                  setState(() {
                                    isLoading = true;
                                  });
                                }),
                            errorMaxLines: 2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                              ),
                            ),
                          ),
                          autocorrect: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0, bottom: 16.0),
                        child: SubmitButton(
                  title: "Checkout",
                  act: () async {
                            if (isCash == "") {
                              presentToast('Select payment mode', context, 0);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Checkout(
                                      isCash: isCash,
                                      from: "Shopping Cart",
                                      grandTotal:
                                          double.parse(getTotalPrice()) -
                                              couponValue,
                                      couponDiscount: couponValue,
                                      productname: mycartData.length > 0
                                          ? mycartData[0]['product']['name']
                                          : ""),
                                ),
                              );
                            }}
                      
                   
                ), )]))
              )
            : serviceCalled
                ? Center(
                    child: Image.asset("assets/empty_cart.png"),
                  )
                : SizedBox());
  }

  Container buildShoppingCartItem(BuildContext context, item) {
    return Container(
      padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: (MediaQuery.of(context).size.width) / 3,
              child: Column(
                children: <Widget>[
                  CachedNetworkImage(
                      imageUrl: item['product']['thumbnail_img'],
                      height: 120,
                      width: 100,
                      fit: BoxFit.fitHeight),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            updateCart(item['id'].toString(),
                                mycartData.indexOf(item), "dec");
                          },
                        ),
                        Text(
                          item['quantity'].toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            updateCart(item['id'].toString(),
                                mycartData.indexOf(item), "inc");
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width - 37) / 1.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 12.0),
                        width: 150,
                        child: Text(
                          item['product']['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 26,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          removeCartProduct(
                              item['id'].toString(), mycartData.indexOf(item));
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "\u20B9 " + item['product']['unit_price'].toString(),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Size",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          item['attributes_custom']['size'],
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Color",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          item['attributes_custom']['color'],
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          item['quantity'].toString(),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "\u20B9 " + item['product']['discounted_price'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            item['product']['discount'] + " % off",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyCoupon(String code) {
    getProgressDialog(context, "Applying Coupon...").show();
    commeonMethod5(api_url + "check-coupon?code=$code",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        if (DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
                int.parse(data["data"]["start_date"]) * 1000)) &&
            DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(
                int.parse(data["data"]["end_date"]) * 1000))) {
          setState(() {
            couponValue = data["data"]["discount_type"] == "amount"
                ? double.parse(data["data"]["discount"])
                : (double.parse(data["data"]["discount"]) *
                    double.parse(getTotalPrice()) /
                    100);
          });
        } else {
          print(false);
          print(DateTime.now().millisecondsSinceEpoch);
          print(data["data"]["start_date"]);
          print(data["data"]["end_date"]);
        }
      } else {}

      setState(() {});

      getProgressDialog(context, "").hide(context);
    });
  }

  void getMyCartList() {
    getProgressDialog(context, "Fetching Cart...").show();
    commeonMethod2(api_url + "cart",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          mycartData = data['data'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }

      setState(() {
        serviceCalled = true;
      });

      getProgressDialog(context, "Fetching Cart...").hide(context);
    });
  }

  void updateCart(String id, int index, String val) {
    getProgressDialog(context, "Updating Cart...").show();
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "cart/update"));
    request.fields['cart_id'] = id;
    request.fields['action'] = val;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers["APP"] = "ECOM";
    request.headers["Accept"] = "application/json";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          setState(() {
            if (int.parse(mycartData[index]['quantity']) > 1) {
              if (val == "inc") {
                mycartData[index]['quantity'] =
                    (int.parse(mycartData[index]['quantity']) + 1).toString();
              } else {
                mycartData[index]['quantity'] =
                    (int.parse(mycartData[index]['quantity']) - 1).toString();
              }
            } else {
              if (val == "inc") {
                mycartData[index]['quantity'] =
                    (int.parse(mycartData[index]['quantity']) + 1).toString();
              } else {
                mycartData.removeAt(index);
                Provider.of<UserData>(context, listen: false)
                    .saveCartCount(mycartData.length);
              }
            }
          });
        } else {
          presentToast(data['message'], context, 0);
        }
        getProgressDialog(context, "Fetching Cart...").hide(context);
      });
    });
  }

  void removeCartProduct(String id, int index) {
    getProgressDialog(context, "Removing Item...").show();
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "cart/delete"));
    request.fields['cart_id'] = id;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers["APP"] = "ECOM";
    request.headers["Accept"] = "application/json";
    print(request);
    print(request.headers);
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          setState(() {
            mycartData.removeAt(index);
          });
          Provider.of<UserData>(context, listen: false)
              .saveCartCount(mycartData.length);
        } else {
          presentToast(data['message'], context, 0);
        }

        getProgressDialog(context, "Fetching Cart...").hide(context);
      });
    });
  }

  String getSubTotalPrice() {
    double cost = 0;
    for (var item in mycartData) {
      cost = cost +
          double.parse(item['product']['discounted_price']) *
              double.parse(item['quantity']);
    }
    return cost.toStringAsFixed(2);
  }

  String getTotalPrice() {
    double total = 0;
    if (double.parse(getSubTotalPrice()) < 599) {
      total = double.parse(getSubTotalPrice()) + 49;
    } else {
      total = double.parse(getSubTotalPrice());
    }

    // isCash == "Online Payment"
    //     ? (total - double.parse(getSubTotalPrice()) * 0.02).toStringAsFixed(2)
    //     :
    return total.toStringAsFixed(2);
  }

  showThankYouBottomSheet(BuildContext context, String message1) {
    return _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Lottie.asset('lottie/warning.json',
                      height: MediaQuery.of(context).size.height * 0.3,
                      animate: true),
                ),
              ),
              flex: 5,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text: "\n\n" + message1,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade800),
                          )
                        ])),
                    SizedBox(
                      height: 24,
                    ),
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          isCash = "Online Payment";
                          price.text = "";
                        });
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.only(left: 48, right: 48),
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24))),
                    )
                  ],
                ),
              ),
              flex: 5,
            )
          ],
        ),
      );
    },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        backgroundColor: Colors.white,
        elevation: 2);
  }
}
