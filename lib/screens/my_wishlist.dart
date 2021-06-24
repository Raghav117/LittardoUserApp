import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/productPage.dart';
import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWishList extends StatefulWidget {
  _MyWishList createState() => _MyWishList();
}

class _MyWishList extends State<MyWishList> {
  List wishListData = new List();
  bool serviceCalled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getMyWishList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "My Wishlist",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: (wishListData.length > 0 && serviceCalled)
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return CardData(index);
              },
              itemCount: wishListData.length,
            )
          : (wishListData.length == 0 && serviceCalled)
              ? Center(
                  child: Image.asset("assets/norecordfound.png"),
                )
              : SizedBox(),
    );
  }

  Widget _customicon(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          "assets/imgs/littardo_logo.png",
          height: 500,
          width: 500,
        ),
      ),
      decoration: new BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }

  CardData(int index) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => new ProductPage(
                  product: Product(
                      id: wishListData[index]['product']["id"].toString(),
                      name: wishListData[index]['product']["name"],
                      icon: wishListData[index]['product']["thumbnail_img"],
                      rating: double.parse(
                          wishListData[index]['product']['rating']),
                      remainingQuantity: 5,
                      price:
                          '\u20b9 ${wishListData[index]['product']["discounted_price"]}',
                      isWishlisted: wishListData[index]['product']
                          ['wishlisted_count'],
                      originalPrice: wishListData[index]['product']
                          ['unit_price'],
                      description: wishListData[index]['product']
                          ['description'],
                      discount: wishListData[index]['product']['discount'],
                      photos: wishListData[index]['product']['photos'],
                      currentStock: wishListData[index]['product']
                              ['current_stock']
                          .toString(),
                      shippingCost: wishListData[index]['product']
                              ['shipping_cost']
                          .toString()),
                )));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Flexible(
                    flex: 9,
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl: wishListData[index]['product']
                                ['thumbnail_img'],
                            height: 120,
                            width: 100,
                            fit: BoxFit.fill),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child:
                                    Text(wishListData[index]['product']['name'],
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        "\u20B9 " +
                                            wishListData[index]['product']
                                                    ['unit_price']
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                        "(" +
                                            wishListData[index]['product']
                                                ['discount'] +
                                            "% off)",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.green))
                                  ],
                                ),
                              ),
                              // OutlineButton(
                              //   onPressed: () {
                              //     movetoCart(
                              //         wishListData[index]['product_id'], index);
                              //   },
                              //   highlightElevation: 1.0,
                              //   child: Text(
                              //     "MOVE TO CART",
                              //     style: TextStyle(color: Colors.blue),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 24,
                      ),
                      onPressed: () {
                        removefromwishlist(
                            wishListData[index]['product']['id'].toString(),
                            index);
                      },
                      color: Colors.red,
                    ),
                  )
                ])),
          ),
        ),
      ),
    );
  }

  String getDiscountedPrice(data) {
    return ((190 * 100) / (190 + data)).toStringAsFixed(0);
  }

  void removefromwishlist(String productId, int index) {
    getProgressDialog(context, "Remove from wishlist...").show();
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "wishlist/remove"));
    request.fields['product_id'] = productId;
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
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          setState(() {
            wishListData.removeAt(index);
          });
          try {
            Provider.of<UserData>(context, listen: false).bestselling[
                    Provider.of<UserData>(context, listen: false)
                        .bestselling
                        .indexWhere(
                            (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = "0";
          } catch (e) {}
          try {
            Provider.of<UserData>(context, listen: false).featured[
                    Provider.of<UserData>(context, listen: false)
                        .featured
                        .indexWhere(
                            (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = "0";
          } catch (e) {}
          try {
            Provider.of<UserData>(context, listen: false).hot_deals[
                    Provider.of<UserData>(context, listen: false)
                        .hot_deals
                        .indexWhere(
                            (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = "0";
          } catch (e) {}
          Provider.of<UserData>(context, listen: false).notifyListeners();
        }
        getProgressDialog(context, "Remove from wishlist...").hide(context);
      });
    });
  }

  void getMyWishList() {
    getProgressDialog(context, "Fetching wishlist...").show();
    commeonMethod2(api_url + "wishlist",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          wishListData = data['data'];
        });
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching wishlist...").hide(context);
    });
  }

  void movetoCart(String cartId, int index) {
    getProgressDialog(context, "Adding to cart...").show();
    commeonMethod2(api_url + "app/moveToCart?id=" + cartId,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      presentToast(data['message'], context, 0);
      if (data['code'] == 200) {
        setState(() {
          wishListData.removeAt(index);
        });
      }
      getProgressDialog(context, "Adding to cart...").hide(context);
    });
  }
}
