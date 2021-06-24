import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/painters/circlepainters.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/login.dart';
import 'package:littardo/screens/subscription.dart';
import 'package:littardo/screens/myOrders.dart';
import 'package:littardo/screens/my_wishlist.dart';
import 'package:littardo/screens/products_list.dart';
import 'package:littardo/screens/search.dart';
import 'package:littardo/screens/shoppingcart.dart';
import 'package:littardo/screens/subcategory.dart';
import 'package:littardo/screens/notification_new.dart';
import 'package:littardo/screens/usersettings.dart';
import 'package:littardo/screens/whell.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/constant.dart';
import 'package:littardo/widgets/item_product.dart';
import 'package:littardo/widgets/occasions.dart';
import 'package:littardo/utils/navigator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet.dart';

import 'checkout.dart';
import 'products_list.dart';
import 'categories1.dart';
import 'subscribed.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController searchController = new TextEditingController();
  UserData userDataProvider;

  bool showSearchField = false;
  

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer<UserData>(builder: (context, userData, child) {
        userDataProvider = userData;
        return Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          drawer: Drawer(child: leftDrawerMenu()),
          appBar: buildAppBar(context),
          // bottomNavigationBar: new TabBar(
          //   tabs: [
          //     Tab(
          //       icon: new Icon(Icons.home),
          //     ),
          //     Tab(
          //       icon: new Icon(Icons.attach_money),
          //     ),
          //     Tab(
          //       icon: new Icon(Icons.shopping_cart),
          //     ),
          //     Tab(
          //       icon: new Icon(Icons.account_circle),
          //     )
          //   ],
          //   labelColor: Theme.of(context).primaryColor,
          //   unselectedLabelColor: Colors.blueGrey,
          //   indicatorSize: TabBarIndicatorSize.label,
          //   indicatorPadding: EdgeInsets.all(8.0),
          //   indicatorColor: Colors.red,
          // ),
          body: TabBarView(
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CategoriesListView(),
                      userDataProvider.bannerOffersWidget.length > 0
                          ? buildCarouselSlider()
                          : SizedBox(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Hot Deals",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTrending(userDataProvider.gethot_deals, "hotdeals"),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Featured Products",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTrending(userDataProvider.getfeatured, "featured"),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Best Selling",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTrending(
                          userDataProvider.getbestselling, "bestselling"),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Top Brands",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  userDataProvider.getbrands.length, (index) {
                                return TrendingItem(
                                  updateWishList: () {},
                                  product: Product(
                                      id: userDataProvider.getbrands[index]
                                              ["id"]
                                          .toString(),
                                      name: userDataProvider.getbrands[index]
                                          ["name"],
                                      icon: userDataProvider.getbrands[index]
                                          ["logo"],
                                      type: "brand"),
                                  gradientColors: [
                                    Color(0XFFa466ec),
                                    Colors.purple[400]
                                  ],
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ShoppingCart(false),
            ],
          ),
        );
      }),
    );
  }

  Column buildTrending(List products, String type) {
    return Column(
      children: <Widget>[
        Container(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(products.length, (index) {
              print(products[index]);
              return TrendingItem(
                updateWishList: () {
                  addToWishList(
                      products[index]['wishlisted_count'] == "1"
                          ? "wishlist/remove"
                          : "wishlist/add",
                      products[index]["id"].toString(),
                      type,
                      index);
                },
                product: Product(
                    id: products[index]["id"].toString(),
                    name: products[index]["name"],
                    icon: products[index]["thumbnail_img"],
                    rating: double.parse(products[index]["rating"]),
                    remainingQuantity: 5,
                    price: '${products[index]["discounted_price"]}',
                    isWishlisted: products[index]['wishlisted_count'],
                    originalPrice: products[index]['unit_price'],
                    description: products[index]['description'],
                    photos: products[index]['photos'],
                    discount: products[index]['discount'],
                    currentStock: products[index]['current_stock'].toString(),
                    shippingCost: products[index]['shipping_cost'].toString()),
                gradientColors: [Color(0XFFa466ec), Colors.purple[400]],
              );
            }),
          ),
        )
      ],
    );
  }

  CarouselSlider buildCarouselSlider() {
    return CarouselSlider(
        height: 150,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
        autoPlay: true,
        enlargeCenterPage: true,
        items: userDataProvider.bannerOffersWidget);
  }

  BottomNavyBar buildBottomNavyBar(BuildContext context) {
    return BottomNavyBar(
      selectedIndex: currentIndex,
      showElevation: true,
      onItemSelected: (index) => setState(() {
        currentIndex = index;
      }),
      items: [
        BottomNavyBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          activeColor: Theme.of(context).primaryColor,
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.apps),
            title: Text('Categories'),
            activeColor: Theme.of(context).primaryColor),
        BottomNavyBarItem(
            icon: Badge(
              badgeContent: Text(
                Provider.of<UserData>(context, listen: true).cartCount,
                style: TextStyle(color: Colors.white),
              ),
              badgeColor: Colors.red,
              animationType: BadgeAnimationType.slide,
              child: Icon(
                Icons.shopping_cart,
              ),
            ),
            title: Text('Shopping Cart'),
            activeColor: Theme.of(context).primaryColor),
        BottomNavyBarItem(
            icon: Icon(Icons.shopping_basket),
            title: Text('Orders'),
            activeColor: Theme.of(context).primaryColor),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
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
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) => new ProductList(
                                id: "",
                                name: "",
                                type: "",
                                query: searchController.text)));
                      }
                    },
                  )),
            )
          : Text(
              "Littardo Emporium",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
      leading: new IconButton(
          icon: new Icon(MaterialCommunityIcons.getIconData("menu"),
              color: Colors.black),
          onPressed: () => _scaffoldKey.currentState.openDrawer()),
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              showSearchField = !showSearchField;
            });
          },
          child: Icon(
            MaterialCommunityIcons.getIconData(
                !showSearchField ? "magnify" : "close"),
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: Badge(
            badgeContent: Text(
              Provider.of<UserData>(context, listen: true).cartCount,
              style: TextStyle(color: Colors.white),
            ),
            badgeColor: Colors.red,
            animationType: BadgeAnimationType.slide,
            child: Icon(
              MaterialCommunityIcons.getIconData("cart-outline"),
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
      ],
      backgroundColor: Colors.white,
    );
  }

  Future<Null> clearPreference(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', '');
    prefs.setString('cartCount', null);
    prefs.setString('referral_code', null);
    prefs.setString("compare_list", null);
    prefs.setString('userData', '');
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => new LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void addToWishList(String method, String productId, String type, int index) {
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
          try {
            userDataProvider.bestselling[userDataProvider.bestselling
                    .indexWhere(
                        (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = method == "wishlist/add" ? "1" : "0";
          } catch (e) {}
          try {
            userDataProvider.featured[userDataProvider.featured.indexWhere(
                    (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = method == "wishlist/add" ? "1" : "0";
          } catch (e) {}
          try {
            userDataProvider.hot_deals[userDataProvider.hot_deals.indexWhere(
                    (element) => element['id'].toString() == productId)]
                ['wishlisted_count'] = method == "wishlist/add" ? "1" : "0";
          } catch (e) {}
          userDataProvider.notifyListeners();
        }
        getProgressDialog(context, "Adding to wishlist...").hide(context);
      });
    });
  }

  leftDrawerMenu() {
    Color blackColor = Colors.black.withOpacity(0.6);
    return Container(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            height: 150,
            child: DrawerHeader(
              child: ListTile(
                trailing: Icon(
                  Icons.chevron_right,
                  size: 28,
                ),
                // subtitle: GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //         type: PageTransitionType.fade,
                //         child: UserSettings(),
                //       ),
                //     );
                //   },
                //   child: Text(
                //     "See Profile",
                //     style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w500,
                //         color: blackColor),
                //   ),
                // ),
                title: Text(
                  userDataProvider.userData != null
                      ? userDataProvider.userData['name']
                      : "",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blackColor),
                ),
                leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/user.png"),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFB),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Feather.getIconData('home'),
              color: blackColor,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: blackColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: Home(),
                ),
              );
            },
          ),
          ListTile(
            trailing: Icon(
              Ionicons.getIconData('ios-radio-button-on'),
              color: Color(0xFFFB7C7A),
              size: 18,
            ),
            leading: Icon(Feather.getIconData('briefcase'), color: blackColor),
            title: Text('Wallet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor)),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: MyWallet(),
                ),
              );
            },
          ),
//          ListTile(
//            leading: Icon(Feather.getIconData('search'), color: blackColor),
//            title: Text('Search',
//                style: TextStyle(
//                    fontSize: 16,
//                    fontWeight: FontWeight.w600,
//                    color: blackColor)),
//            onTap: () {
//              Navigator.push(
//                context,
//                PageTransition(
//                  type: PageTransitionType.fade,
//                  child: Search(),
//                ),
//              );
//            },
//          ),
          ListTile(
            trailing: Icon(
              Ionicons.getIconData('ios-radio-button-on'),
              color: Color(0xFFFB7C7A),
              size: 18,
            ),
            leading: Icon(Feather.getIconData('bell'), color: blackColor),
            title: Text('Notifications',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor)),
            onTap: () {
              Nav.route(context, NotificationPage());
            },
          ),
         ListTile(
           
           leading:
               Icon(Icons.subscriptions_outlined, color: blackColor),
           title: Text('Subscription',
               style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: blackColor)),
           onTap: () {
             Navigator.push(
               context,
               PageTransition(
                 type: PageTransitionType.fade,
                 child: SubCategory(),
               ),
             );
           },
         ),
         ListTile(
           
           leading:
               Icon(Icons.subscriptions, color: blackColor),
           title: Text('Subscribed Packages',
               style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: blackColor)),
           onTap: () {
             Navigator.push(
               context,
               PageTransition(
                 type: PageTransitionType.fade,
                 child: SubscribedPackage(),
               ),
             );
           },
         ),
          ListTile(
            leading: Icon(Feather.getIconData('list'), color: blackColor),
            title: Text('My Orders',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MyOrders()));
            },
          ),
          ListTile(
            leading: Icon(Feather.getIconData('list'), color: blackColor),
            title: Text('My WishList',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MyWishList()));
            },
          ),
          // ListTile(
          //   leading: Icon(Feather.getIconData('award'), color: blackColor),
          //   title: Text('Points',
          //       style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //           color: blackColor)),
          //   onTap: () {
          //     Nav.route(context, Checkout());
          //   },
          // ),
          // ListTile(
          //   leading:
          //       Icon(Feather.getIconData('message-circle'), color: blackColor),
          //   title: Text('Support',
          //       style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //           color: blackColor)),
          //   onTap: () {
          //     Nav.route(context, ProductList());
          //   },
          // ),
          // ListTile(
          //   leading:
          //       Icon(Feather.getIconData('help-circle'), color: blackColor),
          //   title: Text('Help',
          //       style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //           color: blackColor)),
          //   onTap: () {
          //     Nav.route(context, UserSettings());
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Feather.getIconData('settings'), color: blackColor),
          //   title: Text('Settings',
          //       style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //           color: blackColor)),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       PageTransition(
          //         type: PageTransitionType.fade,
          //         child: UserSettings(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Feather.getIconData('x-circle'), color: blackColor),
            title: Text('Quit',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor)),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are You sure you want to logout?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          FlatButton(
                              child: Text("Yes"),
                              onPressed: () => {
                                    clearPreference(context),
                                  }),
                        ],
                      ));
            },
          ),
        ],
      ),
    );
  }
}

class CategoriesListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12),
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Provider.of<UserData>(context, listen: false)
                  .getcategories
                  .length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        ctx: context,
                        child: SubCategoryPage(
                          categoryId:
                              Provider.of<UserData>(context, listen: false)
                                  .getcategories[index]["id"]
                                  .toString(),
                          categoryName:
                              Provider.of<UserData>(context, listen: false)
                                  .getcategories[index]["name"],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            width: 55,
                            height: 55,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.blueGrey,
                                width: 1,
                              ),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              child: CachedNetworkImage(
                                imageUrl: Provider.of<UserData>(context,
                                        listen: false)
                                    .getcategories[index]['icon'],
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Provider.of<UserData>(context, listen: false)
                                .getcategories[index]['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
