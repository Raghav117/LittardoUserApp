import 'dart:convert';

import 'package:flutter_icons/ionicons.dart';
import 'package:flutter_icons/material_community_icons.dart';
import 'package:http/http.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/shoppingcart.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/widgets/filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:littardo/widgets/item_product.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProductList extends StatefulWidget {
  final String id;
  final String name;
  final String type;
  final String query;

  const ProductList({Key key, this.id, this.name, this.type, this.query})
      : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List productList = new List();
  String categoryName = "";
  String method = "";
  int pagesize = 1;
  bool serviceCalled = false;
  bool iswishListed = false;

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  PanelController slidingUpController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = new TextEditingController();
  bool showSearchField = false;
  String lastQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.query != "") {
        serachQuery(widget.query);
      } else {
        fetchProducts(widget.type == "cat"
            ? "products?sub_sub_category_id="
            : "products?brand_id=");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 2;
    return Stack(
      children: [
        Container( decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/pattern.jpg"),
            fit: BoxFit.cover,
          ),
        ),),
        Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          appBar: AppBar(
            title: showSearchField
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    style: new TextStyle(
                      color: Colors.black,
                    ),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            if (searchController.text == "") {
                              presentToast("Please enter search query", context, 2);
                            } else {
                              serachQuery(searchController.text);
                            }
                          },
                        )),
                  )
                : Text(
                    lastQuery != "" ? lastQuery : widget.name,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
            leading: IconButton(
              icon:
                  Icon(Ionicons.getIconData("ios-arrow-back"), color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  height: 18.0,
                  width: 18.0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchField = !showSearchField;
                      });
                    },
                    icon: Icon(
                      MaterialCommunityIcons.getIconData(
                          !showSearchField ? "magnify" : "close"),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: SizedBox(
                  height: 18.0,
                  width: 18.0,
                  child: IconButton(
                    icon: Icon(
                      MaterialCommunityIcons.getIconData("cart-outline"),
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
                ),
              ),
            ],
            backgroundColor: Colors.white,
          ),
          body: SlidingUpPanel(
            controller: slidingUpController,
            minHeight: 42,
            color: Colors.blueGrey,
            panel: Filtre(
              productCallBack: getProductListFromFilter,
            ),
            collapsed: Container(
              decoration:
                  BoxDecoration(color: Colors.blueGrey, borderRadius: radius),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  Text(
                    "Filter",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            borderRadius: radius,
            body: productList.length > 0
                ? Container(
                    padding: EdgeInsets.only(top: 18),
                    child: LayoutBuilder(builder: (c, data) {
                      return LazyLoadScrollView(
                        onEndOfPage: () => fetchProducts(widget.type == "cat"
                            ? "products?sub_sub_category_id="
                            : "products?brand_id="),
                        scrollOffset: 100,
                        child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 2),
                            padding: EdgeInsets.all(8),
                            itemCount: productList.length,
                            controller: ScrollController(keepScrollOffset: false),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return Center(
                                child: TrendingItem(
                                  updateWishList: () {
                                    addToWishList(
                                        productList[index]['wishlisted_count'] ==
                                                "1"
                                            ? "wishlist/remove"
                                            : "wishlist/add",
                                        productList[index]["id"].toString(),
                                        index);
                                  },
                                  product: Product(
                                      id: productList[index]['id'].toString(),
                                      name: productList[index]['name'],
                                      icon: productList[index]['thumbnail_img'],
                                      rating: double.parse(
                                          productList[index]['rating']),
                                      remainingQuantity: 5,
                                      price: productList[index]['discounted_price'],
                                      isWishlisted: productList[index]
                                          ['wishlisted_count'],
                                      originalPrice: productList[index]
                                          ['unit_price'],
                                      discount: productList[index]['discount'],
                                      description: productList[index]
                                          ['description'],
                                      photos: productList[index]['photos'],
                                      currentStock: productList[index]
                                          ['current_stock'],
                                      shippingCost: productList[index]
                                              ['shipping_cost']
                                          .toString()),
                                  gradientColors: [
                                    Color(0XFFa466ec),
                                    Colors.purple[400]
                                  ],
                                ),
                              );
                            }),
                      );
                    }))
                : serviceCalled
                    ? Center(
                        child: Image.asset("assets/norecordfound.png"),
                      )
                    : SizedBox(),
          ),
        ),
      ],
    );
  }

  void addToWishList(String method, String productId, int index) {
    getProgressDialog(context, "Adding to wishlist...").show();
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
            productList[index]['wishlisted_count'] =
                method == "wishlist/add" ? "1" : "0";
          });
        }
        getProgressDialog(context, "Adding to wishlist...").hide(context);
      });
    });
  }

  void serachQuery(String query) {
    setState(() {
      serviceCalled = false;
      lastQuery = query;
      productList.clear();
    });
    getProgressDialog(context, "Fetching Products...").show();
    commeonMethod2(api_url + "products?keyword=" + lastQuery,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        productList.addAll(data['data']);
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching Products...").hide(context);
    });
  }

  fetchProducts(String method) {
    getProgressDialog(context, "Fetching Products...").show();
    commeonMethod2(api_url + method + widget.id,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        productList.addAll(data['products']['data']);
        setState(() {
          pagesize += 1;
        });
        print(productList.length);
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching Product...").hide(context);
    });
  }

  getProductListFromFilter(String filterUrl) {
    getProgressDialog(context, "Fetching Products...").show();
    commeonMethod5(filterUrl,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        productList = (data['filter_data']['products']['data']);
        setState(() {
          pagesize += 1;
        });
        print(productList.length);
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching Product...").hide(context);
    });
  }
}
