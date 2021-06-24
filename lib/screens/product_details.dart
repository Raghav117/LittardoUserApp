////import 'dart:convert';
//import 'dart:io';
//import 'dart:typed_data';
//
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:flutter_share_me/flutter_share_me.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_share_me/flutter_share_me.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:http/http.dart';
//import 'package:littardo/cart.dart';
//import 'package:littardo/checkout.dart';
//import 'package:littardo/homepage.dart';
//import 'package:littardo/photo_zoom.dart';
//import 'package:littardo/services/api_services.dart';
//import 'package:littardo/shared/colors.dart';
//import 'package:littardo/utils/custom_textstyle.dart';
//import 'package:littardo/widgets/carousel_slider.dart';
//import 'package:littardo/widgets/fabbottom_bar.dart';
//import 'package:lottie/lottie.dart';
//import 'package:percent_indicator/linear_percent_indicator.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//class ProductDetails extends StatefulWidget {
//  Map productList;
//
//  ProductDetails(Map productList) {
//    this.productList = productList;
//  }
//
//  @override
//  _ProductDetailsState createState() => _ProductDetailsState(productList);
//}
//
//class _ProductDetailsState extends State<ProductDetails>
//    with WidgetsBindingObserver {
//  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
//  Map user;
//  List imgList = [];
//  bool descTextShowFlag = false;
//  int current_stock = 1;
//  int _current = 0;
//  final Widget placeholder = Container(color: Colors.grey);
//  List listSize = new List();
//  List listFabric = new List();
//  List listColor = new List();
//  var selectedSize = 0;
//  var selectedFabric = 0;
//  var selectedColor = 0;
//  bool isWishlisted = false;
//
//  bool _isLoading = false;
//  Map productList;
//
//  bool addedtocart = false;
//
//  String product_code;
//  String rating_count;
//
//  Map rating_counts;
//  List rating_review = new List();
//
//  TextEditingController mobile = new TextEditingController();
//
//  _ProductDetailsState(Map productList) {
//    this.productList = productList;
//    this.imgList = productList['photos'];
//    if (productList['wishlisted_count'] == "1") {
//      isWishlisted = true;
//    }
//  }
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    checkIsLogin();
//  }
//
//  Future<Null> checkIsLogin() async {
//    String _token = "";
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    _token = prefs.getString("token");
//    if (_token != "" && _token != null) {
//      user = jsonDecode(prefs.getString("user"));
//      getRatingInfo();
//      //your home page is loaded
//    } else {
//      print("not logged in.");
//    }
//  }
//
//  Widget _customicon(BuildContext context, int index) {
//    return Container(
//      child: Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: Image.asset(
//          "assets/imgs/littardo_logo.png",
//          height: 500,
//          width: 500,
//        ),
//      ),
//      decoration: new BoxDecoration(
//          color: Color(0xffffffff),
//          borderRadius: new BorderRadius.circular(5.0)),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//      onWillPop: () {
//        Navigator.pop(context, isWishlisted);
//      },
//      child: Stack(
//        children: <Widget>[
//          Scaffold(
//            key: _scaffoldKey,
//            floatingActionButtonLocation:
//                FloatingActionButtonLocation.centerDocked,
//            floatingActionButton: FloatingActionButton(
//              onPressed: () {
//                addToWishList(
//                  productList['wishlisted_count'] == "1"
//                      ? "wishlist/remove"
//                      : "wishlist/add",
//                  user['api_token'],
//                  productList['id'].toString(),
//                );
//              },
//              child: isWishlisted
//                  ? Icon(Icons.favorite)
//                  : Icon(Icons.favorite_border),
//              backgroundColor: isWishlisted ? Colors.red : Colors.grey,
//              elevation: 2.0,
//            ),
//            bottomNavigationBar: FABBottomAppBar(
//              centerItemText: '',
//              color: Colors.grey,
//              selectedColor: Colors.red,
//              notchedShape: CircularNotchedRectangle(),
//              items: [
//                Container(
//                  child: FlatButton(
//                      onPressed: () {
//                        if (addedtocart) {
//                          setState(() {
//                            addedtocart = false;
//                          });
//                          Navigator.of(context).push(new MaterialPageRoute(
//                              builder: (context) =>
//                                  new MyCart("My Cart", null)));
//                        } else {
//                          if (int.parse(productList['current_stock']) > 0) {
//                            addToCart("cart/add", "cart");
//                          } else {
//                            presentToast('Product is out of stock', context, 0);
//                          }
//                        }
//                      },
//                      child: FittedBox(
//                        child: Row(
//                          children: <Widget>[
//                            Icon(Icons.shopping_cart, color: Colors.orange),
//                            Text(
//                              addedtocart ? "GO TO CART" : "ADD TO CART",
//                              style: TextStyle(color: Colors.orange),
//                            )
//                          ],
//                        ),
//                      )),
//                ),
//                Container(
//                  child: FlatButton(
//                      onPressed: () {
//                        if (int.parse(productList['current_stock']) > 0) {
//                          addToCart("cart/add?buy", "buy");
//                        } else {
//                          presentToast('Product is out of stock', context, 0);
//                        }
//                      },
//                      child: FittedBox(
//                        child: Row(
//                          children: <Widget>[
//                            Image.asset(
//                              'assets/bag.png',
//                              fit: BoxFit.fill,
//                              height: 24,
//                              width: 24,
//                            ),
//                            Text(
//                              "BUY NOW",
//                              style: TextStyle(color: Colors.red),
//                            )
//                          ],
//                        ),
//                      )),
//                )
//              ],
//            ),
//            appBar: AppBar(
//              backgroundColor: Colors.red,
//              title: Text(
//                productList['name'],
//                style: CustomTextStyle.boldTextStyle.copyWith(
//                    color: Colors.white.withOpacity(0.9), fontSize: 18),
//              ),
//              leading: new IconButton(
//                  icon: new Icon(Icons.arrow_back, color: Colors.white),
//                  onPressed: () => {Navigator.pop(context, isWishlisted)}),
//              actions: <Widget>[
//                InkWell(
//                  onTap: () async {
//                    setState(() {
//                      _isLoading = true;
//                    });
//                    var request = await HttpClient()
//                        .getUrl(Uri.parse(productList['main_image_url']));
//                    var response = await request.close();
//                    Uint8List bytes =
//                        await consolidateHttpClientResponseBytes(response);
//                    var content = productList['name'] +
//                        "\nProduct code - " +
//                        product_code +
//                        "\n" +
//                        productList['product_description'];
//                    FlutterShareMe()
//                        .shareToWhatsApp(
//                            base64Image:
//                                "data:image/jpeg;base64," + base64Encode(bytes),
//                            msg: content)
//                        .then((response) {
//                      print(response);
////                          handleResponse(response, appName: "Whatsapp");
//                      if (response == "success") {
//                        saveShareCat();
//                      } else {
//                        presentToast(
//                            'WhatsApp Business not supported', context, 0);
//                      }
//                      setState(() {
//                        _isLoading = false;
//                      });
//                    });
//                  },
//                  child: Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: Icon(Icons.share),
//                  ),
//                ),
//                InkWell(
//                  onTap: () {
//                    Navigator.pushAndRemoveUntil(
//                      context,
//                      new MaterialPageRoute(
//                          builder: (context) => new HomePage()),
//                      (Route<dynamic> route) => false,
//                    );
//                  },
//                  child: Icon(
//                    Icons.home,
//                    color: white,
//                  ),
//                )
//              ],
//            ),
//            body: SingleChildScrollView(
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  buildCard(),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Flexible(
//                        flex: 8,
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            (listFabric.length > 0 &&
//                                    listFabric[0] != "NA" &&
//                                    listFabric[0] != "N/A")
//                                ? Container(
//                                    alignment: Alignment.topLeft,
//                                    margin: EdgeInsets.only(left: 8),
//                                    child: Text(
//                                      "Fabric",
//                                      style: CustomTextStyle
//                                          .blackTextStyleMedium
//                                          .copyWith(fontSize: 12),
//                                    ),
//                                  )
//                                : SizedBox(),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: buildChoice(),
//                            ),
//                            (listColor.length > 0 &&
//                                    listColor[0] != "NA" &&
//                                    listColor[0] != "N/A")
//                                ? Container(
//                                    alignment: Alignment.topLeft,
//                                    margin: EdgeInsets.only(left: 8),
//                                    child: Text(
//                                      "Color",
//                                      style: CustomTextStyle
//                                          .blackTextStyleMedium
//                                          .copyWith(fontSize: 12),
//                                    ),
//                                  )
//                                : SizedBox(),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: buildChoiceColor(),
//                            ),
//                            (listSize.length > 0 &&
//                                    listSize[0] != "NA" &&
//                                    listSize[0] != "N/A")
//                                ? Container(
//                                    alignment: Alignment.topLeft,
//                                    margin: EdgeInsets.only(left: 8),
//                                    child: Text(
//                                      "Size",
//                                      style: CustomTextStyle
//                                          .blackTextStyleMedium
//                                          .copyWith(fontSize: 12),
//                                    ),
//                                  )
//                                : SizedBox(),
//                            (listSize.length > 0 &&
//                                    listSize[0] != "NA" &&
//                                    listSize[0] != "N/A")
//                                ? Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: Wrap(
//                                      children: List<Widget>.generate(
//                                        listSize.length,
//                                        (int index) {
//                                          return Padding(
//                                            padding: const EdgeInsets.only(
//                                                right: 8.0),
//                                            child: ChoiceChip(
//                                              label: Text(listSize[index]),
//                                              selected: selectedSize == index,
//                                              onSelected: (bool selected) {
//                                                setState(() {
//                                                  selectedSize =
//                                                      selected ? index : null;
//                                                });
//                                                getPriceInfo();
//                                              },
//                                            ),
//                                          );
//                                        },
//                                      ).toList(),
//                                    ))
//                                : SizedBox(),
//                          ],
//                        ),
//                      ),
//                      Flexible(
//                        flex: 5,
//                        child: Padding(
//                          padding: const EdgeInsets.only(right: 8.0),
//                          child: Container(
//                            padding: EdgeInsets.all(10),
//                            decoration: BoxDecoration(
//                                border: Border.all(color: Colors.grey),
//                                borderRadius: BorderRadius.circular(50)),
//                            child: Wrap(children: <Widget>[
//                              new InkWell(
//                                child: new Icon(
//                                  Icons.remove,
//                                  size: 24,
//                                ),
//                                onTap: () {
//                                  setState(() {
//                                    current_stock = --current_stock == 0
//                                        ? 1
//                                        : current_stock;
//                                  });
//                                },
//                              ),
//                              new Padding(
//                                  padding: EdgeInsets.symmetric(horizontal: 20),
//                                  child: new Text(current_stock.toString(),
//                                      style: TextStyle(fontSize: 20))),
//                              new InkWell(
//                                child: new Icon(
//                                  Icons.add,
//                                  size: 24,
//                                ),
//                                onTap: () {
//                                  setState(() {
//                                    current_stock++;
//                                  });
//                                },
//                              ),
//                            ]),
//                          ),
//                        ),
//                      )
//                    ],
//                  ),
//                  Card(
//                    child: Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Container(
//                        width: double.infinity,
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Padding(
//                              padding: const EdgeInsets.only(bottom: 8.0),
//                              child: Text(productList['name'],
//                                  style: CustomTextStyle.mediumTextStyle
//                                      .copyWith(fontSize: 14)),
//                            ),
//                            Row(
//                              children: <Widget>[
//                                Text('\u20B9 ' + productList['unit_price'],
//                                    style:
//                                        CustomTextStyle.boldTextStyle.copyWith(
//                                      fontSize: 16,
//                                      color: Theme.of(context).brightness ==
//                                              Brightness.dark
//                                          ? Colors.green
//                                          : Colors.teal,
//                                    )),
//                                Padding(
//                                  padding: const EdgeInsets.only(left: 8.0),
//                                  child: Text(
//                                      '\u20B9 ' + productList['unit_price'],
//                                      style: CustomTextStyle.mediumTextStyle
//                                          .copyWith(
//                                              fontSize: 14,
//                                              color: Theme.of(context)
//                                                          .brightness ==
//                                                      Brightness.dark
//                                                  ? Colors.red
//                                                  : Colors.orange,
//                                              decoration:
//                                                  TextDecoration.lineThrough)),
//                                ),
//                              ],
//                            ),
//                            Padding(
//                              padding: const EdgeInsets.only(top: 4.0),
//                              child: Text('Shipping Charges \u20B9 49',
//                                  style: CustomTextStyle.mediumTextStyle
//                                      .copyWith(
//                                          fontSize: 14,
//                                          color: Theme.of(context).brightness ==
//                                                  Brightness.dark
//                                              ? Colors.green
//                                              : Colors.teal)),
//                            ),
//                            Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: <Widget>[
//                                Wrap(
//                                  crossAxisAlignment: WrapCrossAlignment.center,
//                                  children: <Widget>[
//                                    Container(
//                                      margin:
//                                          EdgeInsets.only(left: 8, right: 4),
//                                      child: Icon(
//                                          int.parse(productList[
//                                                      'current_stock']) >
//                                                  0
//                                              ? Icons.check
//                                              : Icons.error,
//                                          size: 15,
//                                          color: Colors.white),
//                                      decoration: ShapeDecoration(
//                                          color: int.parse(productList[
//                                                      'current_stock']) >
//                                                  0
//                                              ? Colors.green
//                                              : Colors.orange,
//                                          shape: CircleBorder()),
//                                      height: 20,
//                                    ),
//                                    Text(
//                                        int.parse(productList[
//                                                    'current_stock']) >
//                                                0
//                                            ? 'In Stock'
//                                            : "Out of Stock",
//                                        style: CustomTextStyle.mediumTextStyle
//                                            .copyWith(
//                                                fontSize: 14,
//                                                color: int.parse(productList[
//                                                            'current_stock']) >
//                                                        0
//                                                    ? Colors.green
//                                                    : Colors.orange)),
//                                  ],
//                                ),
//                                int.parse(productList['current_stock']) == 0
//                                    ? RaisedButton(
//                                        color: Colors.blue,
//                                        padding: EdgeInsets.all(0),
//                                        onPressed: () {
//                                          showDialog(
//                                              context: context,
//                                              builder: (context) => AlertDialog(
//                                                    title: Text("Notify"),
//                                                    content:
//                                                        SingleChildScrollView(
//                                                      child: Column(
//                                                        mainAxisSize:
//                                                            MainAxisSize.min,
//                                                        children: <Widget>[
//                                                          Padding(
//                                                            padding:
//                                                                const EdgeInsets
//                                                                    .all(4.0),
//                                                            child:
//                                                                new TextField(
//                                                              autofocus: true,
//                                                              controller:
//                                                                  mobile,
//                                                              maxLength: 11,
//                                                              keyboardType:
//                                                                  TextInputType
//                                                                      .number,
//                                                              decoration:
//                                                                  new InputDecoration(
//                                                                      counterStyle:
//                                                                          TextStyle(
//                                                                        height:
//                                                                            double.minPositive,
//                                                                      ),
//                                                                      counterText:
//                                                                          "",
//                                                                      labelText:
//                                                                          "Enter mobile number",
//                                                                      contentPadding: EdgeInsets.symmetric(
//                                                                          vertical:
//                                                                              5,
//                                                                          horizontal:
//                                                                              8),
//                                                                      border:
//                                                                          new OutlineInputBorder(
//                                                                        borderRadius:
//                                                                            new BorderRadius.circular(5.0),
//                                                                        borderSide:
//                                                                            new BorderSide(),
//                                                                      )),
//                                                            ),
//                                                          ),
//                                                        ],
//                                                      ),
//                                                    ),
//                                                    actions: <Widget>[
//                                                      FlatButton(
//                                                        child: Text("Notify"),
//                                                        onPressed: () {
//                                                          if (mobile
//                                                                  .text.length <
//                                                              10) {
//                                                            presentToast(
//                                                                "Enter valid mobile number",
//                                                                context,
//                                                                2);
//                                                          } else {
//                                                            Navigator.pop(
//                                                                context, false);
//                                                            presentToast(
//                                                                "You will be notified",
//                                                                context,
//                                                                0);
//                                                          }
//                                                        },
//                                                      ),
//                                                    ],
//                                                  ));
//                                        },
//                                        highlightElevation: 1.0,
//                                        shape: RoundedRectangleBorder(
//                                            borderRadius:
//                                                BorderRadius.circular(25)),
//                                        child: Text(
//                                          "NOTIFY ME",
//                                          style:
//                                              TextStyle(color: Colors.white70),
//                                        ),
//                                      )
//                                    : SizedBox()
//                              ],
//                            ),
//                            Padding(
//                              padding: const EdgeInsets.only(top: 8.0),
//                              child: Wrap(
//                                crossAxisAlignment: WrapCrossAlignment.start,
//                                children: <Widget>[
//                                  Icon(
//                                    Icons.directions_car,
//                                    color: Colors.blue,
//                                    size: 20,
//                                  ),
//                                  Wrap(
//                                    direction: Axis.vertical,
//                                    children: <Widget>[
//                                      RichText(
//                                          text: TextSpan(
//                                              text: "Free ",
//                                              style: CustomTextStyle
//                                                  .mediumTextStyle
//                                                  .copyWith(
//                                                fontSize: 10,
//                                                color: Colors.green,
//                                              ),
//                                              children: [
//                                            TextSpan(
//                                                text: "\u20b9 49",
//                                                style: CustomTextStyle
//                                                    .mediumTextStyle
//                                                    .copyWith(
//                                                        fontSize: 10,
//                                                        color: Colors.grey,
//                                                        decoration:
//                                                            TextDecoration
//                                                                .lineThrough)),
//                                          ])),
//                                      Padding(
//                                        padding: const EdgeInsets.only(top: 2),
//                                        child: Text("If ordered before 9:20 PM",
//                                            style: CustomTextStyle
//                                                .mediumTextStyle
//                                                .copyWith(
//                                              fontSize: 10,
//                                              color: Colors.grey,
//                                            )),
//                                      ),
//                                    ],
//                                  )
//                                ],
//                              ),
//                            ),
//                            Padding(
//                                padding: const EdgeInsets.only(top: 8.0),
//                                child: Wrap(
//                                    crossAxisAlignment:
//                                        WrapCrossAlignment.center,
//                                    children: <Widget>[
//                                      Icon(
//                                        Icons.cancel,
//                                        color: Colors.red,
//                                        size: 20,
//                                      ),
//                                      Text("5 Day's return policy",
//                                          style: CustomTextStyle.mediumTextStyle
//                                              .copyWith(
//                                            fontSize: 12,
//                                            color: Colors.grey,
//                                          ))
//                                    ])),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Text(
//                                  "Discounts on prepaid\n\nGet additional 2% discount on every prepaid order",
//                                  maxLines: descTextShowFlag ? 3 : 1,
//                                  style:
//                                      CustomTextStyle.mediumTextStyle.copyWith(
//                                    fontSize: 12,
//                                    color: Colors.grey,
//                                  )),
//                            ),
//                            !descTextShowFlag
//                                ? InkWell(
//                                    onTap: () {
//                                      setState(() {
//                                        descTextShowFlag = !descTextShowFlag;
//                                      });
//                                    },
//                                    child: Padding(
//                                      padding: const EdgeInsets.only(
//                                          left: 8.0, bottom: 8),
//                                      child: Text("View Offers",
//                                          textAlign: TextAlign.center,
//                                          style: CustomTextStyle.mediumTextStyle
//                                              .copyWith(
//                                            fontSize: 10,
//                                            color: Colors.green,
//                                          )),
//                                    ),
//                                  )
//                                : SizedBox(),
////                            InkWell(
////                              onTap: (){
////                                setState(() {
////                                  descTextShowFlag = !descTextShowFlag;
////                                });
////                              },
////                              child: Padding(
////                                padding: const EdgeInsets.only(left:8.0,bottom: 8),
////                                child: Text(
////                                  "View Less",
////                                  style: CustomTextStyle.mediumTextStyle
////                                      .copyWith(
////                                    fontSize: 10,
////                                    color: Colors.red,
////                                  ),
////                                ),
////                              ),
////                            )
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
//                  buildDescription("Highlights", productList['description']),
//                  productList['rating'] != null && rating_review.length > 0
//                      ? Column(
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.all(10),
//                              child: Row(
//                                children: <Widget>[
//                                  Flexible(
//                                    flex: 1,
//                                    child: Text("Ratings & Reviews",
//                                        style: TextStyle(
//                                            fontSize: 16,
//                                            fontWeight: FontWeight.bold)),
//                                  ),
//                                  Flexible(
//                                    flex: 2,
//                                    child: Center(
//                                      child: Column(
//                                        children: <Widget>[
//                                          Row(
//                                            mainAxisAlignment:
//                                                MainAxisAlignment.center,
//                                            children: <Widget>[
//                                              Text(
//                                                  productList['rating'] != null
//                                                      ? productList['rating']
//                                                      : "0",
//                                                  style:
//                                                      TextStyle(fontSize: 30)),
//                                              SizedBox(
//                                                width: 6,
//                                              ),
//                                              Icon(
//                                                Icons.star,
//                                                size: 30,
//                                              ),
//                                            ],
//                                          ),
//                                          SizedBox(
//                                            height: 8,
//                                          ),
//                                          Text(productList['rating'] +
//                                              " ratings and " +
//                                              rating_review.length.toString() +
//                                              " reviews")
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                                ],
//                              ),
//                            ),
//                            Column(
//                              children: rating_review.map((item){
//                                return getReviewCard(item);
//                              }).toList(),
//                            )
//                          ],
//                        )
//                      : SizedBox(),
//                  SizedBox(
//                    height: 56,
//                  )
////          Expanded(
////            child: buildAddToRow(),
////          ),
//                ],
//              ),
//            ),
//          ),
//          _isLoading
//              ? new Stack(
//                  children: [
//                    new Opacity(
//                      opacity: 0.3,
//                      child: const ModalBarrier(
//                          dismissible: false, color: Colors.grey),
//                    ),
//                    new Center(
//                      child: SpinKitRotatingPlain(
//                        itemBuilder: _customicon,
//                      ),
//                    ),
//                  ],
//                )
//              : SizedBox()
//        ],
//      ),
//    );
//  }
//
//  Widget createSizeItem(int index) {
//    return GestureDetector(
//      onTap: () {
//        setState(() {
//          selectedSize = index;
//        });
//      },
//      child: Container(
//        width: 28,
//        margin: EdgeInsets.all(4),
//        height: 28,
//        padding: EdgeInsets.only(top: 10),
//        child: Text(
//          listSize[index],
//          style: CustomTextStyle.mediumTextStyle.copyWith(
//              fontSize: 9, color: selectedSize == index ? white : Colors.black),
//          textAlign: TextAlign.center,
//        ),
//        decoration: BoxDecoration(
//            color: selectedSize == index ? Colors.green : Colors.white,
//            border: Border.all(
//                color: selectedSize == index ? Colors.green : Colors.grey,
//                width: 1),
//            shape: BoxShape.circle),
//      ),
//    );
//  }
//
//  List<T> map<T>(List list, Function handler) {
//    List<T> result = [];
//    for (var i = 0; i < list.length; i++) {
//      result.add(handler(i, list[i]));
//    }
//
//    return result;
//  }
//
//  Widget buildCard() {
//    return Column(children: [
//      CarouselSlider(
//        items: imgList.map(
//          (url) {
//            return InkWell(
//              onTap: () {
//                Navigator.of(context).push(new MaterialPageRoute(
//                    builder: (context) =>
//                        new PhotoZoom(imgList.indexOf(url), imgList)));
//              },
//              child: Container(
//                margin: EdgeInsets.all(5.0),
//                child: ClipRRect(
//                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  child: CachedNetworkImage(
//                    imageUrl: url,
//                    fit: BoxFit.fill,
//                  ),
//                ),
//              ),
//            );
//          },
//        ).toList(),
//        autoPlay: false,
//        enlargeCenterPage: false,
//        enableInfiniteScroll: false,
//        aspectRatio: 1.2,
//        onPageChanged: (index) {
//          setState(() {
//            _current = index;
//          });
//        },
//      ),
//      Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: map<Widget>(
//          imgList,
//          (index, url) {
//            return Container(
//              width: 8.0,
//              height: 8.0,
//              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
//              decoration: BoxDecoration(
//                  shape: BoxShape.circle,
//                  color: _current == index
//                      ? Theme.of(context).brightness == Brightness.dark
//                          ? Color.fromRGBO(227, 199, 244, 0.9)
//                          : Color.fromRGBO(0, 0, 0, 0.9)
//                      : Theme.of(context).brightness == Brightness.dark
//                          ? Color.fromRGBO(227, 199, 244, 0.4)
//                          : Color.fromRGBO(0, 0, 0, 0.4)),
//            );
//          },
//        ),
//      ),
//    ]);
//  }
//
//  Widget buildChoice() {
//    // TODO: change color to a drop down menu
//    return Row(
//      mainAxisSize: MainAxisSize.max,
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//      children: <Widget>[
//        (listFabric.length > 0 &&
//                listFabric[0] != "NA" &&
//                listFabric[0] != "N/A")
//            ? Wrap(
//                children: listFabric.map((item) {
//                  return buildFabric(listFabric.indexOf(item));
//                }).toList(),
//              )
//            : SizedBox(),
//      ],
//    );
//  }
//
//  Widget buildChoiceColor() {
//    // TODO: change color to a drop down menu
//    return Row(
//      mainAxisSize: MainAxisSize.max,
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//      children: <Widget>[
//        (listColor.length > 0 && listColor[0] != "NA" && listColor[0] != "N/A")
//            ? Wrap(
//                children: listColor.map((item) {
//                  return buildColor(listColor.indexOf(item));
//                }).toList(),
//              )
//            : SizedBox(),
//      ],
//    );
//  }
//
//  Widget buildFabric(int index) {
//    return GestureDetector(
//      onTap: () {
//        setState(() {
//          selectedFabric = index;
//        });
//      },
//      child: Container(
//        margin: EdgeInsets.only(left: 4),
//        child: Wrap(
//          direction: Axis.vertical,
//          crossAxisAlignment: WrapCrossAlignment.center,
//          children: <Widget>[
//            Text(
//              listFabric[index],
//              style: CustomTextStyle.mediumTextStyle.copyWith(
//                fontSize: 12,
//              ),
//              textAlign: TextAlign.center,
//            ),
//            selectedFabric == index
//                ? Icon(
//                    Icons.check_circle,
//                    size: 28,
//                    color: Colors.green,
//                  )
//                : Icon(
//                    Icons.radio_button_unchecked,
//                    size: 28,
//                    color: Colors.grey,
//                  )
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget buildColor(int index) {
//    return GestureDetector(
//      onTap: () {
//        setState(() {
//          selectedColor = index;
//        });
//      },
//      child: Container(
//        margin: EdgeInsets.only(left: 4),
//        child: Wrap(
//          direction: Axis.vertical,
//          crossAxisAlignment: WrapCrossAlignment.center,
//          children: <Widget>[
//            selectedColor == index
//                ? Icon(
//                    Icons.check_circle,
//                    size: 28,
//                    color: Color(int.parse(
//                        "0xff" + listColor[index].replaceAll("#", ""))),
//                  )
//                : Icon(
//                    Icons.radio_button_unchecked,
//                    size: 28,
//                    color: Colors.grey,
//                  )
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget buildDescription(String title, String content) {
//    return Padding(
//      padding: const EdgeInsets.all(8.0),
//      child: Wrap(
//        direction: Axis.vertical,
//        children: <Widget>[
//          Text(
//            title,
//            style: CustomTextStyle.blackTextStyleMedium.copyWith(fontSize: 14),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(left: 8.0, top: 8),
//            child: Text(content != null ? content : "",
//                style: CustomTextStyle.regularTextStyle
//                    .copyWith(fontSize: 14, color: Colors.grey)),
//          )
//        ],
//      ),
//    );
//  }
//
//  void containerForSheet<T>({BuildContext context, Widget child}) {
//    showCupertinoModalPopup<T>(
//      context: context,
//      builder: (BuildContext context) => child,
//    ).then<void>((T value) {});
//  }
//
//  getRatingInfo() {
//    setState(() {
//      _isLoading = true;
//    });
//    commeonMethod2(
//            api_url + "getProductInfo?id=" + productList['id'].toString(),
//            user['api_token'])
//        .then((onResponse) {
//      setState(() {
//        _isLoading = false;
//      });
//      Map data = json.decode(onResponse.body);
//      print(data);
//      if (data['code'] == 200) {
//        product_code = data['product']['product_code'].toString();
//        if (data['product']['choice_options'].length > 0) {
//          listSize = data['product']['choice_options'][0]['values'];
//          listFabric = data['product']['choice_options'][1]['values'];
//          listColor = data['product']['colors'];
//        }
//
//        print(data['product']['reviews']);
//        if (data['product']['reviews'] != null) {
//          rating_review = data['product']['reviews'];
//        }
//      } else {
//        presentToast(data['message'], context, 0);
//      }
//    });
//  }
//
//  _leading(type) {
//    return Row(
//      children: <Widget>[
//        PrefCount(type),
//        SizedBox(
//          width: 3,
//        ),
//        Icon(
//          Icons.star_border,
//          size: 18,
//        ),
//      ],
//    );
//  }
//
//  PrefCount(type) {
//    if (type == 5) {
//      return Text("5", style: TextStyle(fontSize: 16));
//    } else if (type == 4) {
//      return Text("4", style: TextStyle(fontSize: 16));
//    } else if (type == 3) {
//      return Text("3", style: TextStyle(fontSize: 16));
//    } else if (type == 2) {
//      return Text(
//        "2",
//        style: TextStyle(fontSize: 16),
//      );
//    } else {
//      return Text(
//        "1",
//        style: TextStyle(fontSize: 16),
//      );
//    }
//  }
//
//  void addToCart(String method, String from) {
//    setState(() {
//      _isLoading = true;
//    });
////    Map attributes = {
////      "color": listColor.length>0?listColor[selectedColor]:"NA",
////      "size": listSize.length>0?listSize[selectedSize]:"NA"
////    };
//    var request = new MultipartRequest("POST", Uri.parse(api_url + method));
//    request.fields['product_id'] = productList['id'].toString();
//    request.fields["user_id"] = productList['user_id'];
//    request.fields["price"] = productList['unit_price'];
//    request.fields["quantity"] = current_stock.toString();
//    request.fields["color"] =
//        listColor.length > 0 ? listColor[selectedColor] : "NA";
//    request.fields["size"] =
//        listSize.length > 0 ? listSize[selectedSize] : "NA";
//    request.fields["product_id"] = productList['id'].toString();
//    request.fields["shipping_cost"] = productList['shipping_cost'];
//    request.headers['Authorization'] = "Bearer " + user['api_token'];
//    request.headers["APP"] = "ECOM";
//    request.headers["Accept"] = "application/json";
//    print(request);
//    print(request.headers);
//    print(request.fields);
//    commonMethod(request).then((onResponse) {
//      onResponse.stream.transform(utf8.decoder).listen((value) async {
//        setState(() {
//          _isLoading = false;
//        });
//        Map data = json.decode(value);
//        print(data);
//        if (data['code'] == 200) {
//          if (from == "cart") {
//            SharedPreferences prefs = await SharedPreferences.getInstance();
//            prefs.setString("cartCount", data['cart_count'].toString());
//            setState(() {
//              addedtocart = true;
//            });
//            showThankYouBottomSheet(
//                context, data['message'], "", "success", from);
//          } else {
//            Navigator.of(context).pop();
//            Navigator.of(context).push(new MaterialPageRoute(
//                builder: (context) => new MyCart("Checkout", data['data'])));
//          }
//        } else if (data['code'] == 402) {
//          showThankYouBottomSheet(
//              context, data['message1'], data['message2'], "error", from);
//        } else {
//          showThankYouBottomSheet(context, data['message'], "", "error", from);
//        }
//      });
//    });
//  }
//
//  showThankYouBottomSheet(BuildContext context, String message1,
//      String message2, String status, String from) {
//    return _scaffoldKey.currentState.showBottomSheet((context) {
//      return Container(
//        height: 400,
//        decoration: BoxDecoration(
//            color: Colors.white,
//            border: Border.all(color: Colors.grey.shade200, width: 2),
//            borderRadius: BorderRadius.only(
//                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
//        child: Column(
//          children: <Widget>[
//            Expanded(
//              child: Container(
//                child: Align(
//                  alignment: Alignment.bottomCenter,
//                  child: Lottie.asset(
//                      status == "success"
//                          ? 'lottie/success.json'
//                          : 'lottie/warning.json',
//                      height: MediaQuery.of(context).size.height * 0.3,
//                      animate: true),
//                ),
//              ),
//              flex: 5,
//            ),
//            Expanded(
//              child: Container(
//                margin: EdgeInsets.only(left: 16, right: 16),
//                child: Column(
//                  children: <Widget>[
//                    RichText(
//                        textAlign: TextAlign.center,
//                        text: TextSpan(children: [
//                          TextSpan(
//                            text: "\n\n" + message1 + "\n\n" + message2,
//                            style: CustomTextStyle.mediumTextStyle.copyWith(
//                                fontSize: 14, color: Colors.grey.shade800),
//                          )
//                        ])),
//                    SizedBox(
//                      height: 24,
//                    ),
//                    message2 == ""
//                        ? RaisedButton(
//                            onPressed: () {
//                              Navigator.pop(context);
////                              Navigator.pushAndRemoveUntil(
////                                context,
////                                new MaterialPageRoute(
////                                    builder: (context) => new HomePage()),
////                                (Route<dynamic> route) => false,
////                              );
//                            },
//                            padding: EdgeInsets.only(left: 48, right: 48),
//                            child: Text(
//                              "OK",
//                              style: CustomTextStyle.mediumTextStyle
//                                  .copyWith(color: Colors.white),
//                            ),
//                            color: Colors.pink,
//                            shape: RoundedRectangleBorder(
//                                borderRadius:
//                                    BorderRadius.all(Radius.circular(24))),
//                          )
//                        : Wrap(
//                            children: <Widget>[
//                              RaisedButton(
//                                onPressed: () {
//                                  Navigator.of(context).pop();
//                                  addToCart("app/addToCartUpdate", from);
//                                },
//                                padding: EdgeInsets.only(left: 48, right: 48),
//                                child: Text(
//                                  "Yes",
//                                  style: CustomTextStyle.mediumTextStyle
//                                      .copyWith(color: Colors.white),
//                                ),
//                                color: Colors.green,
//                                shape: RoundedRectangleBorder(
//                                    borderRadius:
//                                        BorderRadius.all(Radius.circular(24))),
//                              ),
//                              RaisedButton(
//                                onPressed: () {
//                                  Navigator.of(context).pop();
//                                },
//                                padding: EdgeInsets.only(left: 48, right: 48),
//                                child: Text(
//                                  "No",
//                                  style: CustomTextStyle.mediumTextStyle
//                                      .copyWith(color: Colors.white),
//                                ),
//                                color: Colors.red,
//                                shape: RoundedRectangleBorder(
//                                    borderRadius:
//                                        BorderRadius.all(Radius.circular(24))),
//                              )
//                            ],
//                          )
//                  ],
//                ),
//              ),
//              flex: 5,
//            )
//          ],
//        ),
//      );
//    },
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
//        backgroundColor: Colors.white,
//        elevation: 2);
//  }
//
//  void addToWishList(String method, String accessToken, String productId) {
//    print(method);
//    setState(() {
//      _isLoading = true;
//    });
//    print(accessToken);
//    var request = new MultipartRequest("POST", Uri.parse(api_url + method));
//    request.fields['product_id'] = productId;
//    request.headers['Authorization'] = "Bearer " + accessToken;
//    request.headers["APP"] = "ECOM";
//    request.headers["Accept"] = "application/json";
//    print(request);
//    print(request.headers);
//    print(request.fields);
//    commonMethod(request).then((onResponse) {
//      onResponse.stream.transform(utf8.decoder).listen((value) {
//        setState(() {
//          _isLoading = false;
//        });
//        Map data = json.decode(value);
//        print(data);
//        presentToast(data['message'], context, 0);
//        if (data['code'] == 200) {
//          setState(() {
//            if (method == "wishlist/add") {
//              isWishlisted = true;
//              productList['wishlisted_count'] = 1;
//            } else {
//              isWishlisted = false;
//              productList['wishlisted_count'] = 0;
//            }
//          });
//        }
//      });
//    });
//  }
//
//  void saveShareCat() {
//    setState(() {
//      _isLoading = true;
//    });
//    Map data = {"product_id": productList['id'].toString()};
//    commeonMethod3(api_url + "app/share", data, user['api_token'], "", context)
//        .then((onResponse) async {
//      setState(() {
//        _isLoading = false;
//      });
//    });
//  }
//
//  void getPriceInfo() {
//    setState(() {
//      _isLoading = true;
//    });
//    var request =
//        new MultipartRequest("POST", Uri.parse(api_url + "product_variant"));
//    request.fields["id"] = productList['id'].toString();
//    request.fields["attribute_id_1"] = listSize[selectedSize];
//    request.fields["attribute_id_2"] = listFabric[selectedFabric];
//    request.fields["color"] = listColor[selectedColor];
//    request.fields["quantity"] = current_stock.toString();
//    request.headers['Authorization'] = "Bearer " + user['api_token'];
//    request.headers["APP"] = "ECOM";
//    print(request);
//    print(request.headers);
//    print(request.fields);
//    commonMethod(request).then((onResponse) {
//      onResponse.stream.transform(utf8.decoder).listen((value) async {
//        setState(() {
//          _isLoading = false;
//        });
//        Map data = json.decode(value);
//        print(data);
//        setState(() {
//          productList["unit_price"] = data["price"].toString();
//          productList["current_stock"] = data["quantity"].toString();
//        });
//      });
//    });
//  }
//
//  Widget getReviewCard(item) {
//    return Card(
//      child: Container(
//        width: MediaQuery.of(context).size.width,
//        child:  Wrap(
//          direction: Axis.vertical,
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Text(
//                item['comment'],
//                style: TextStyle(fontSize: 12),
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: RatingBar(
//                initialRating: double.parse(item['rating']),
//                minRating: 0.5,
//                itemSize: 15,
//                direction: Axis.horizontal,
//                ignoreGestures: true,
//                allowHalfRating: false,
//                itemCount: 5,
//                itemPadding:
//                EdgeInsets.symmetric(horizontal: 2.0),
//                itemBuilder: (context, _) => Icon(
//                  Icons.star,
//                  color: Colors.blue[900],
//                ),
//                onRatingUpdate: (rating) {
//                  print(rating);
//                },
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
