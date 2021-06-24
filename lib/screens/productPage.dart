import 'dart:convert';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/photo_zoom.dart';
import 'package:littardo/screens/search.dart';
import 'package:littardo/screens/shoppingcart.dart';
import 'package:littardo/screens/usersettings.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/colors.dart';
import 'package:littardo/widgets/dotted_slider.dart';
import 'package:littardo/widgets/item_product.dart';
import 'package:littardo/widgets/star_rating.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'compare_products.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  ProductPage({this.product});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isClicked = false;
  bool descTextShowFlag = false;
  int current_stock = 1;
  int _current = 0;
  final Widget placeholder = Container(color: Colors.grey);
  List listSize = List();
  List listFabric = List();
  List listColor = List();
  var selectedSize = 0;
  var selectedFabric = 0;
  var selectedColor = 0;
  bool isWishlisted = false;
  List realatedProduct = new List();
  bool addedtocart = false;

  String product_code;
  String rating_count;

  String lastPrice = "";
  String seller_name = "";
  String originallastPrice = "";
  String lastStock = "";
  String lastWishListed = "";
  Map rating_counts;
  List rating_review = List();

  TextEditingController mobile = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    lastPrice = widget.product.price;
    lastStock = widget.product.currentStock;
    originallastPrice = widget.product.originalPrice;
    lastWishListed = widget.product.isWishlisted;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getRatingInfo();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          color: Theme.of(context).backgroundColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 11,
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: <Widget>[
                        SizedBox(
                          child: Divider(
                            color: Colors.black26,
                            height: 4,
                          ),
                          height: 24,
                        ),
                        Column(
                          children: [],
                        ),
                        Text(
                          originallastPrice != ""
                              ? "\u20b9 " + originallastPrice
                              : "",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          "\u20b9 " + lastPrice,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                      ],
                    ),
                    Text(
                      double.parse(widget.product.discount).toStringAsFixed(2) +
                          "% off",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
//             Container(
//              color: Colors.transparent,
//              child:  Container(
//                  width: 48,
//                  height: 48,
//                  decoration:  BoxDecoration(
//                    border: Border.all(width: 1.0, color: Colors.black26),
//                    borderRadius:  BorderRadius.all(
//                      Radius.circular(8.0),
//                    ),
//                  ),
//                  child:  Center(
//                    child:  Icon(
//                      Ionicons.getIconData("ios-share"),
//                      color: Colors.black54,
//                    ),
//                  )),
//            ),

//            RaisedButton(
//              onPressed: () {
//                Navigator.pushReplacement(
//                  context,
//                  MaterialPageRoute(builder: (context) => Checkout()),
//                );
//              },
//              textColor: Colors.white,
//              padding: const EdgeInsets.all(0.0),
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(8.0),
//              ),
//              child: Container(
//
//                height: 60,
//                decoration: const BoxDecoration(
//                  gradient: LinearGradient(
//                    colors: <Color>[
//                      CustomColors.PurpleLight,
//                      CustomColors.PurpleDark,
//                    ],
//                  ),
//                  borderRadius: BorderRadius.all(
//                    Radius.circular(8.0),
//                  ),
//                  boxShadow: [
//                    BoxShadow(
//                      color: CustomColors.PurpleShadow,
//                      blurRadius: 15.0,
//                      spreadRadius: 7.0,
//                      offset: Offset(0.0, 0.0),
//                    )
//                  ],
//                ),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//
//                    Icon(
//                      MaterialCommunityIcons.getIconData(
//                        "gift",
//                      ),
//                      color: Colors.white,
//                    ),
//                     Text(
//                      "Buy Now",
//                      style: TextStyle(color: Colors.white),
//                    ),
//                  ],
//                ),
//              ),
//            ),
                SizedBox(
                  width: 6,
                ),
                RaisedButton(
                  onPressed: () {
                    // _alert(context);
                    if (addedtocart) {
                      setState(() {
                        addedtocart = false;
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ShoppingCart(true)));
                    } else {
                      if (int.parse(lastStock) > 0) {
                        addToCart("cart/add", "cart");
                      } else {
                        presentToast('Product is out of stock', context, 0);
                      }
                    }
                  },
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.9,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          CustomColors.GreenLight,
                          CustomColors.GreenDark,
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CustomColors.GreenShadow,
                          blurRadius: 15.0,
                          spreadRadius: 7.0,
                          offset: Offset(0.0, 0.0),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          MaterialCommunityIcons.getIconData(
                            "cart-outline",
                          ),
                          color: Colors.white,
                        ),
                        Text(
                          addedtocart ? "GO TO CART" : "ADD TO CART",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: Search(),
                          ),
                        );
                      },
                      child: Icon(
                        MaterialCommunityIcons.getIconData("magnify"),
                        color: Colors.black,
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        IconButton(
                          icon: Badge(
                            badgeContent: Text(
                              Provider.of<UserData>(context, listen: true)
                                  .cartCount,
                              style: TextStyle(color: Colors.white),
                            ),
                            badgeColor: Colors.red,
                            animationType: BadgeAnimationType.slide,
                            child: Icon(
                              MaterialCommunityIcons.getIconData(
                                "cart-outline",
                              ),
                              color: Colors.black,
                            ),
                          ),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: ShoppingCart(true),
                              ),
                            );
                          },
                        ),
                        isClicked
                            ? Positioned(
                                left: 9,
                                bottom: 13,
                                child: Icon(
                                  Icons.looks_one,
                                  size: 14,
                                  color: Colors.red,
                                ),
                              )
                            : Text(""),
                      ],
                    ),
                  ],
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  backgroundColor: Colors.white,
                  expandedHeight: MediaQuery.of(context).size.height / 1.8,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      this.widget.product.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    background: dottedSlider(),
                  ),
                ),
              ];
            },
            body: Container(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                (listFabric.length > 0 &&
                                        listFabric[0] != "NA" &&
                                        listFabric[0] != "N/A")
                                    ? Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          "Fabric",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildChoice(),
                                ),
                                (listColor.length > 0 &&
                                        listColor[0] != "NA" &&
                                        listColor[0] != "N/A")
                                    ? Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          "Color",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildChoiceColor(),
                                ),
                                (listSize.length > 0 &&
                                        listSize[0] != "NA" &&
                                        listSize[0] != "N/A")
                                    ? Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          "Size",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )
                                    : SizedBox(),
                                (listSize.length > 0 &&
                                        listSize[0] != "NA" &&
                                        listSize[0] != "N/A")
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Wrap(
                                          children: List<Widget>.generate(
                                            listSize.length,
                                            (int index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: ChoiceChip(
                                                  label: Text(listSize[index]),
                                                  selected:
                                                      selectedSize == index,
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      selectedSize = selected
                                                          ? index
                                                          : null;
                                                    });
                                                    getPriceInfo();
                                                  },
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ))
                                    : SizedBox(),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Wrap(children: <Widget>[
                                  InkWell(
                                    child: Icon(
                                      Icons.remove,
                                      size: 24,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        current_stock = --current_stock == 0
                                            ? 1
                                            : current_stock;
                                      });
                                    },
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(current_stock.toString(),
                                          style: TextStyle(fontSize: 20))),
                                  InkWell(
                                    child: Icon(
                                      Icons.add,
                                      size: 24,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        current_stock++;
                                      });
                                    },
                                  ),
                                ]),
                              ),
                            ),
                          )
                        ],
                      ),
                      Card(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 8,
                                          child: Text(widget.product.name,
                                              style: TextStyle(fontSize: 14)),
                                        ),
                                        Flexible(
                                          flex: 4,
                                          child: Text(
                                              seller_name != ""
                                                  ? "Seller - " + seller_name
                                                  : "",
                                              style: TextStyle(fontSize: 14)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Shipping Charges \u20B9 49',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.green
                                                    : Colors.teal)),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 8, right: 4),
                                            child: Icon(
                                                int.parse(lastStock) > 0
                                                    ? Icons.check
                                                    : Icons.error,
                                                size: 15,
                                                color: Colors.white),
                                            decoration: ShapeDecoration(
                                                color: int.parse(lastStock) > 0
                                                    ? Colors.green
                                                    : Colors.orange,
                                                shape: CircleBorder()),
                                            height: 20,
                                          ),
                                          Text(
                                              int.parse(lastStock) > 0
                                                  ? 'In Stock'
                                                  : "Out of Stock",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      int.parse(lastStock) > 0
                                                          ? Colors.green
                                                          : Colors.orange)),
                                        ],
                                      ),
                                      int.parse(lastStock) == 0
                                          ? RaisedButton(
                                              color: Colors.blue,
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                  "Notify"),
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
                                                                            mobile,
                                                                        maxLength:
                                                                            11,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        decoration: InputDecoration(
                                                                            counterStyle: TextStyle(
                                                                              height: double.minPositive,
                                                                            ),
                                                                            counterText: "",
                                                                            labelText: "Enter mobile number",
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
                                                                      "Notify"),
                                                                  onPressed:
                                                                      () {
                                                                    if (mobile
                                                                            .text
                                                                            .length <
                                                                        10) {
                                                                      presentToast(
                                                                          "Enter valid mobile number",
                                                                          context,
                                                                          2);
                                                                    } else {
                                                                      Navigator.pop(
                                                                          context,
                                                                          false);
                                                                      presentToast(
                                                                          "You will be notified",
                                                                          context,
                                                                          0);
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ));
                                              },
                                              highlightElevation: 1.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Text(
                                                "NOTIFY ME",
                                                style: TextStyle(
                                                    color: Colors.white70),
                                              ),
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.directions_car,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        Wrap(
                                          direction: Axis.vertical,
                                          children: <Widget>[
                                            RichText(
                                                text: TextSpan(
                                                    text: "Free ",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.green,
                                                    ),
                                                    children: [
                                                  TextSpan(
                                                      text: "\u20b9 49",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough)),
                                                ])),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                  "If ordered before 9:20 PM",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            Text("5 Day's return policy",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ))
                                          ])),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "Discounts on prepaid\n\nGet additional 2% discount on every prepaid order",
                                        maxLines: descTextShowFlag ? 3 : 1,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        )),
                                  ),
                                  !descTextShowFlag
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              descTextShowFlag =
                                                  !descTextShowFlag;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, bottom: 8),
                                            child: Text("View Offers",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                )),
                                          ),
                                        )
                                      : SizedBox(),
                                  _buildDescription(context),
                                  _buildComments(context),
                                  _buildProducts(context),
                                ],
                              ),
                            )),
                      )
                    ])))));
  }

  void addToCart(String method, String from) {
    getProgressDialog(context, "Adding to cart...").show();
//    Map attributes = {
//      "color": listColor.length>0?listColor[selectedColor]:"NA",
//      "size": listSize.length>0?listSize[selectedSize]:"NA"
//    };
    var request = MultipartRequest("POST", Uri.parse(api_url + method));
    request.fields['product_id'] = widget.product.id;
    request.fields["user_id"] =
        Provider.of<UserData>(context, listen: false).userData['id'].toString();
    request.fields["price"] = lastPrice;
    request.fields["quantity"] = current_stock.toString();
    request.fields["color"] =
        listColor.length > 0 ? listColor[selectedColor] : "NA";
    request.fields["size"] =
        listSize.length > 0 ? listSize[selectedSize] : "NA";
    request.fields["shipping_cost"] = widget.product.shippingCost;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers["APP"] = "ECOM";
    request.headers["Accept"] = "application/json";
    print(request);
    print(request.headers);
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        getProgressDialog(context, "Adding to cart...").hide(context);
        if (data['code'] == 200) {
          if (from == "cart") {
            Provider.of<UserData>(context, listen: false)
                .saveCartCount(data['cart_count']);
            setState(() {
              addedtocart = true;
            });
            showThankYouBottomSheet(
                context, data['message'], "", "success", from);
          } else {
            // Navigator.of(context).pop();
            // Navigator.of(context).push( MaterialPageRoute(
            //     builder: (context) =>  MyCart("Checkout", data['data'])));
          }
        } else if (data['code'] == 402) {
          showThankYouBottomSheet(
              context, data['message1'], data['message2'], "error", from);
        } else {
          showThankYouBottomSheet(context, data['message'], "", "error", from);
        }
      });
    });
  }

  showThankYouBottomSheet(BuildContext context, String message1,
      String message2, String status, String from) {
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
                  child: Lottie.asset(
                      status == "success"
                          ? 'lottie/success.json'
                          : 'lottie/warning.json',
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
                            text: "\n\n" + message1 + "\n\n" + message2,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade800),
                          )
                        ])),
                    SizedBox(
                      height: 24,
                    ),
                    message2 == ""
                        ? RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
//                              Navigator.pushAndRemoveUntil(
//                                context,
//                                 MaterialPageRoute(
//                                    builder: (context) =>  HomePage()),
//                                (Route<dynamic> route) => false,
//                              );
                            },
                            padding: EdgeInsets.only(left: 48, right: 48),
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.pink,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                          )
                        : Wrap(
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  addToCart("app/addToCartUpdate", from);
                                },
                                padding: EdgeInsets.only(left: 48, right: 48),
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24))),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                padding: EdgeInsets.only(left: 48, right: 48),
                                child: Text(
                                  "No",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24))),
                              )
                            ],
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

  void addToWishList(String method, String accessToken, String productId) {
    getProgressDialog(context, "Adding to wishlist...").show();
    print(accessToken);
    var request = MultipartRequest("POST", Uri.parse(api_url + method));
    request.fields['product_id'] = productId;
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
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          setState(() {
            if (method == "wishlist/add") {
              isWishlisted = true;
              lastWishListed = "1";
            } else {
              isWishlisted = false;
              lastWishListed = "0";
            }
          });
        }
        getProgressDialog(context, "Adding to wishlist...").hide(context);
      });
    });
  }

  void saveShareCat() {
    getProgressDialog(context, "Saving shared...").show();
    Map data = {"product_id": widget.product.id.toString()};
    commeonMethod3(
            api_url + "app/share",
            data,
            Provider.of<UserData>(context, listen: false).userData['api_token'],
            "",
            context)
        .then((onResponse) async {
      getProgressDialog(context, "Saving shared...").hide(context);
    });
  }

  getRatingInfo() {
    getProgressDialog(context, "Fetching Details...").show();
    commeonMethod2(api_url + "getProductInfo?id=" + widget.product.id,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        setState(() {
          realatedProduct = data['related_products'];
          seller_name = data['seller_name'];
          product_code = data['product']['product_code'].toString();
          if (data['product']['choice_options'].length > 0) {
            listSize = data['product']['choice_options'][0]['values'];
            if (data['product']['choice_options'].length > 1) {
              listFabric = data['product']['choice_options'][1]['values'];
            }
            listColor = data['product']['colors'];
          }
          if (data['product']['reviews'] != null) {
            rating_review = data['product']['reviews'];
          }
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      getProgressDialog(context, "Fetching Cart...").hide(context);
    });
  }

  void getPriceInfo() {
    getProgressDialog(context, "Fetching Details...").show();
    var request =
        MultipartRequest("POST", Uri.parse(api_url + "product_variant"));
    request.fields["id"] = widget.product.id;
    if (listSize.length > 0) {
      request.fields["attribute_id_1"] = listSize[selectedSize];
    }
    if (listFabric.length > 0) {
      request.fields["attribute_id_2"] = listFabric[selectedFabric];
    }
    if (listColor.length > 0) {
      request.fields["color"] = listColor[selectedColor];
    }
    request.fields["quantity"] = current_stock.toString();
    // request.headers['Authorization'] = "Bearer " +
    //     Provider.of<UserData>(context, listen: false).userData['api_token'];
    // request.headers["APP"] = "ECOM";
    print(request);
    // print(request.headers);
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data);
        setState(() {
          lastPrice = "\u20b9 " + data["price"].toString();
          lastStock = data["quantity"].toString();
        });
        getProgressDialog(context, "Fetching Cart...").hide(context);
      });
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Shopping Cart"),
      content: Text("Your product has been added to cart."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _alert(BuildContext context) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.shrink,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Color.fromRGBO(0, 179, 134, 1.0),
      ),
    );
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Shopping Cart",
      desc: "Your product has been added to cart.",
      buttons: [
        DialogButton(
          child: Text(
            "BACK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "GO CART",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: ShoppingCart(true),
            ),
          ),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  _productSlideImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PhotoZoom(
                widget.product.photos.indexOf(imageUrl),
                widget.product.photos)));
      },
      child: Container(
          child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) {
          return Image.asset("assets/littardo_logo.jpg");
        },
      )
          ),
    );
  }
  dottedSlider() {
    return DottedSlider(
        maxHeight: MediaQuery.of(context).size.height / 1.8,
        children: List.generate(widget.product.photos.length, (index) {
          return _productSlideImage(widget.product.photos[index]);
        }));
  }

  Widget createSizeItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = index;
        });
      },
      child: Container(
        width: 28,
        margin: EdgeInsets.all(4),
        height: 28,
        padding: EdgeInsets.only(top: 10),
        child: Text(
          listSize[index],
          style: TextStyle(
              fontSize: 9,
              color: selectedSize == index ? Colors.white : Colors.black),
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(
            color: selectedSize == index ? Colors.green : Colors.white,
            border: Border.all(
                color: selectedSize == index ? Colors.green : Colors.grey,
                width: 1),
            shape: BoxShape.circle),
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget buildChoice() {
    // TODO: change color to a drop down menu
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        (listFabric.length > 0 &&
                listFabric[0] != "NA" &&
                listFabric[0] != "N/A")
            ? Wrap(
                children: listFabric.map((item) {
                  return buildFabric(listFabric.indexOf(item));
                }).toList(),
              )
            : SizedBox(),
      ],
    );
  }

  Widget buildChoiceColor() {
    // TODO: change color to a drop down menu
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        (listColor.length > 0 && listColor[0] != "NA" && listColor[0] != "N/A")
            ? Wrap(
                children: listColor.map((item) {
                  return buildColor(listColor.indexOf(item));
                }).toList(),
              )
            : SizedBox(),
      ],
    );
  }

  Widget buildFabric(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFabric = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: 4),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              listFabric[index],
              style: TextStyle(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            selectedFabric == index
                ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    size: 28,
                    color: Colors.grey,
                  )
          ],
        ),
      ),
    );
  }

  Widget buildColor(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: 4),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            selectedColor == index
                ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Color(int.parse(
                        "0xff" + listColor[index].replaceAll("#", ""))),
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    size: 28,
                    color: Colors.grey,
                  )
          ],
        ),
      ),
    );
  }

  _buildDescription(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.8,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    fontSize: 18,
                  ),
                ),
                RaisedButton(
                  color: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    Provider.of<UserData>(context, listen: false)
                        .updateCompare(widget.product)
                        .then((value) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CompareProducts(
                                product: widget.product,
                              )));
                    });
                  },
                  highlightElevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    "ADD TO COMPARE",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget.product.description ?? "",
              maxLines: 3,
            ),
            SizedBox(
              height: 8,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  _settingModalBottomSheet(context, widget.product.description);
                },
                child: Text(
                  "View More",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildComments(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.black12),
          bottom: BorderSide(width: 1.0, color: Colors.black12),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Comments",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                StarRating(rating: widget.product.rating, size: 20),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "${rating_review.length} Comments",
                  style: TextStyle(color: Colors.black54),
                )
              ],
            ),
            SizedBox(
              child: Divider(
                color: Colors.black26,
                height: 4,
              ),
              height: 24,
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: rating_review.length,
                itemBuilder: (context, index) {
                  print(rating_review[index]);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/user.png"),
                    ),
                    subtitle: Text(rating_review[index]['comment']),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        StarRating(
                            rating:
                                double.parse(rating_review[index]['rating']),
                            size: 15),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          rating_review[index]['formatted_time'],
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  _buildProducts(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Similar Items",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        buildTrending()
      ],
    );
  }

  Column buildTrending() {
    return Column(
      children: <Widget>[
        Container(
          height: 180,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(realatedProduct.length, (index) {
                return TrendingItem(
                  product: Product(
                      id: realatedProduct[index]["id"].toString(),
                      name: realatedProduct[index]["name"],
                      icon: realatedProduct[index]["thumbnail_img"],
                      rating: double.parse(realatedProduct[index]["rating"]),
                      remainingQuantity: 5,
                      price: '${realatedProduct[index]["discounted_price"]}',
                      isWishlisted: realatedProduct[index]['wishlisted_count'],
                      originalPrice: realatedProduct[index]['unit_price'],
                      discount: realatedProduct[index]['discount'],
                      description: realatedProduct[index]['description'],
                      photos: realatedProduct[index]['photos'],
                      currentStock:
                          realatedProduct[index]['current_stock'].toString(),
                      shippingCost:
                          realatedProduct[index]['shipping_cost'].toString()),
                  gradientColors: [Color(0XFFa466ec), Colors.purple[400]],
                );
              })),
        )
      ],
    );
  }
}

void _settingModalBottomSheet(context, description) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(description),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
