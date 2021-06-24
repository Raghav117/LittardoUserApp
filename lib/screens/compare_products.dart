import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/widgets/dotted_slider.dart';
import 'package:littardo/widgets/split_screen.dart';
import 'package:littardo/models/product.dart';
import 'package:littardo/widgets/star_rating.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

class CompareProducts extends StatefulWidget {
  final Product product;

  const CompareProducts({Key key, this.product}) : super(key: key);

  _CompareProducts createState() => _CompareProducts();
}

class _CompareProducts extends State<CompareProducts> {
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

  bool isClickedC = false;
  bool descTextShowFlagC = false;
  int current_stockC = 1;
  int _currentC = 0;
  final Widget placeholderC = Container(color: Colors.grey);
  List listSizeC = List();
  List listFabricC = List();
  List listColorC = List();
  var selectedSizeC = 0;
  var selectedFabricC = 0;
  var selectedColorC = 0;
  bool isWishlistedC = false;
  List realatedProductC = new List();
  bool addedtocartC = false;

  String product_codeC;
  String rating_countC;

  String lastPriceC = "";
  String seller_nameC = "";
  String originallastPriceC = "";
  String lastStockC = "";
  String lastWishListedC = "";
  Map rating_countsC;
  List rating_reviewC = List();

  Product productToCompare;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    lastPrice = widget.product.price;
    lastStock = widget.product.currentStock;
    originallastPrice = widget.product.originalPrice;
    lastWishListed = widget.product.isWishlisted;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getRatingInfo(widget.product, true);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              Icon(Ionicons.getIconData("ios-arrow-back"), color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Compare",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SplitView(
        initialWeight: 0.5,
        viewMode: SplitViewMode.Horizontal,
        view1: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownSearch<Product>(
                        mode: Mode.BOTTOM_SHEET,
                        label: "Choose Product",
                        searchBoxDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 0, 8, 0),
                          labelText: "Search a country",
                        ),
                        items: Provider.of<UserData>(context, listen: false)
                            .getCompareList,
                        popupShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        onChanged: (Product data) {
                          setState(() {
                            productToCompare = data;
                            lastPrice = widget.product.price;
                            lastStockC = productToCompare.currentStock;
                            originallastPriceC = productToCompare.originalPrice;
                            lastWishListedC = productToCompare.isWishlisted;
                            getRatingInfo(productToCompare, false);
                          });
                        },
                        dropdownBuilder: _customDropDownExample,
                        popupItemBuilder: _customPopupItemBuilderExample),
                  ),
                  productToCompare != null ? dottedSlider(false) : SizedBox(),
                  productToCompare != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Flexible(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    (listFabricC.length > 0 &&
                                            listFabricC[0] != "NA" &&
                                            listFabricC[0] != "N/A")
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
                                      child: buildChoice(false),
                                    ),
                                    (listColorC.length > 0 &&
                                            listColorC[0] != "NA" &&
                                            listColorC[0] != "N/A")
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
                                      child: buildChoiceColor(false),
                                    ),
                                    (listSizeC.length > 0 &&
                                            listSizeC[0] != "NA" &&
                                            listSizeC[0] != "N/A")
                                        ? Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 8),
                                            child: Text(
                                              "Size",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          )
                                        : SizedBox(),
                                    (listSizeC.length > 0 &&
                                            listSizeC[0] != "NA" &&
                                            listSizeC[0] != "N/A")
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Wrap(
                                              children: List<Widget>.generate(
                                                listSizeC.length,
                                                (int index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: ChoiceChip(
                                                      label: Text(
                                                          listSizeC[index]),
                                                      selected: selectedSizeC ==
                                                          index,
                                                      onSelected:
                                                          (bool selected) {
                                                        setState(() {
                                                          selectedSizeC =
                                                              selected
                                                                  ? index
                                                                  : null;
                                                        });
                                                        getPriceInfo(false);
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
                            ])
                      : SizedBox(),
                  productToCompare != null
                      ? Card(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 8,
                                            child: Text(productToCompare.name,
                                                style: TextStyle(fontSize: 14)),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: Text(
                                                seller_nameC != ""
                                                    ? "Seller - " + seller_nameC
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
                                              color: Theme.of(context)
                                                          .brightness ==
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
                                                  int.parse(lastStockC) > 0
                                                      ? Icons.check
                                                      : Icons.error,
                                                  size: 15,
                                                  color: Colors.white),
                                              decoration: ShapeDecoration(
                                                  color:
                                                      int.parse(lastStockC) > 0
                                                          ? Colors.green
                                                          : Colors.orange,
                                                  shape: CircleBorder()),
                                              height: 20,
                                            ),
                                            Text(
                                                int.parse(lastStockC) > 0
                                                    ? 'In Stock'
                                                    : "Out of Stock",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        int.parse(lastStockC) >
                                                                0
                                                            ? Colors.green
                                                            : Colors.orange)),
                                          ],
                                        ),
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
                                                padding: const EdgeInsets.only(
                                                    top: 2),
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
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
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
                                    _buildDescription(context, false),
                                  ],
                                ),
                              )),
                        )
                      : SizedBox()
                ]))),
        view2: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  dottedSlider(true),
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
                                child: buildChoice(true),
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
                                child: buildChoiceColor(true),
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
                                                selected: selectedSize == index,
                                                onSelected: (bool selected) {
                                                  setState(() {
                                                    selectedSize =
                                                        selected ? index : null;
                                                  });
                                                  getPriceInfo(true);
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
                      ]),
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
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green
                                            : Colors.teal)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 8, right: 4),
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
                                              color: int.parse(lastStock) > 0
                                                  ? Colors.green
                                                  : Colors.orange)),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
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
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                            ])),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child:
                                              Text("If ordered before 9:20 PM",
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
                                          descTextShowFlag = !descTextShowFlag;
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
                              _buildDescription(context, true),
                            ],
                          ),
                        )),
                  )
                ]))),
        onWeightChanged: (w) => print("Horizon: $w"),
      ),
    );
  }

  Widget _customPopupItemBuilderExample(
      BuildContext context, Product item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
        // subtitle: Text(item.createdAt.toString()),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.icon),
        ),
      ),
    );
  }

  Widget _customDropDownExample(
      BuildContext context, Product item, String itemDesignation) {
    return Container(
      child: (item?.icon == null)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              // leading: CircleAvatar(),
              title: Text("No item selected"),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(item.icon),
              ),
              title: Text(item.name),
              // subtitle: Text(
              //   item.createdAt.toString(),
            ),
    );
  }

  getRatingInfo(Product product, bool status) {
    getProgressDialog(context, "Fetching Details...").show();
    commeonMethod2(api_url + "getProductInfo?id=" + product.id,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        setState(() {
          if (status) {
            realatedProduct = data['related_products'];
            seller_name = data['seller_name'];
            product_code = data['product']['product_code'].toString();
            if (data['product']['choice_options'].length > 0) {
              listSize = data['product']['choice_options'][0]['values'];
              listFabric = data['product']['choice_options'][0]['values'];
              listColor = data['product']['colors'];
            }
            if (data['product']['reviews'] != null) {
              rating_review = data['product']['reviews'];
            }
          } else {
            realatedProductC = data['related_products'];
            seller_nameC = data['seller_name'];
            product_codeC = data['product']['product_code'].toString();
            if (data['product']['choice_options'].length > 0) {
              listSizeC = data['product']['choice_options'][0]['values'];
              listFabricC = data['product']['choice_options'][0]['values'];
              listColorC = data['product']['colors'];
            }
            if (data['product']['reviews'] != null) {
              rating_reviewC = data['product']['reviews'];
            }
          }
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      getProgressDialog(context, "Fetching Cart...").hide(context);
    });
  }

  void getPriceInfo(bool status) {
    getProgressDialog(context, "Fetching Details...").show();
    var request =
        MultipartRequest("POST", Uri.parse(api_url + "product_variant"));
    request.fields["id"] = status ? widget.product.id : productToCompare.id;
    request.fields["attribute_id_1"] =
        status ? listSize[selectedSize] : listSizeC[selectedSizeC];
    request.fields["attribute_id_2"] =
        status ? listFabric[selectedFabric] : listFabricC[selectedFabricC];
    request.fields["color"] =
        status ? listColor[selectedColor] : listColorC[selectedColorC];
    request.fields["quantity"] =
        status ? current_stock.toString() : current_stockC;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers["APP"] = "ECOM";
    print(request);
    print(request.headers);
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data);
        setState(() {
          if (status) {
            lastPrice = "\u20b9 " + data["price"].toString();
            lastStock = data["quantity"].toString();
            originallastPrice = "";
          } else {
            lastPriceC = "\u20b9 " + data["price"].toString();
            lastStockC = data["quantity"].toString();
            originallastPriceC = "";
          }
        });
        getProgressDialog(context, "Fetching Cart...").hide(context);
      });
    });
  }

  _buildDescription(BuildContext context, bool status) {
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
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              status
                  ? widget.product.description
                  : productToCompare.description ?? "",
              maxLines: 3,
            ),
            SizedBox(
              height: 8,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  _settingModalBottomSheet(
                      context,
                      status
                          ? widget.product.description
                          : productToCompare.description ?? "");
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

  _productSlideImage(String imageUrl) {
    return Container(
        child: Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, _, __) {
        return Image.asset("assets/littardo_logo.jpg");
      },
    )

        // CachedNetworkImage(

        //   imageUrl: imageUrl,
        //   fit: BoxFit.cover,
        // ),
        );
  }

  dottedSlider(bool status) {
    return DottedSlider(
        maxHeight: 300,
        children: List.generate(
            status
                ? widget.product.photos.length
                : productToCompare.photos.length, (index) {
          return _productSlideImage(status
              ? widget.product.photos[index]
              : productToCompare.photos[index]);
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

  Widget buildChoice(bool status) {
    // TODO: change color to a drop down menu
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        (status &&
                listFabric.length > 0 &&
                listFabric[0] != "NA" &&
                listFabric[0] != "N/A")
            ? Wrap(
                children: listFabric.map((item) {
                  return buildFabric(listFabric.indexOf(item), true);
                }).toList(),
              )
            : (!status &&
                    listFabricC.length > 0 &&
                    listFabricC[0] != "NA" &&
                    listFabricC[0] != "N/A")
                ? Wrap(
                    children: listFabricC.map((item) {
                      return buildFabric(listFabricC.indexOf(item), false);
                    }).toList(),
                  )
                : SizedBox(),
      ],
    );
  }

  Widget buildChoiceColor(bool status) {
    // TODO: change color to a drop down menu
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        (status &&
                listColor.length > 0 &&
                listColor[0] != "NA" &&
                listColor[0] != "N/A")
            ? Wrap(
                children: listColor.map((item) {
                  return buildColor(listColor.indexOf(item), true);
                }).toList(),
              )
            : (!status &&
                    listColorC.length > 0 &&
                    listColorC[0] != "NA" &&
                    listColorC[0] != "N/A")
                ? Wrap(
                    children: listColorC.map((item) {
                      return buildColor(listColorC.indexOf(item), false);
                    }).toList(),
                  )
                : SizedBox(),
      ],
    );
  }

  Widget buildFabric(int index, bool status) {
    return GestureDetector(
      onTap: () {
        setState(() {
          status ? selectedFabric = index : selectedFabricC = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: 4),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              status ? listFabric[index] : listFabricC[index],
              style: TextStyle(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            status && selectedFabric == index
                ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Colors.green,
                  )
                : !status && selectedFabric == index
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

  Widget buildColor(int index, bool status) {
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
            status && selectedColor == index
                ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Color(int.parse(
                        "0xff" + listColor[index].replaceAll("#", ""))),
                  )
                : !status && selectedColorC == index
                    ? Icon(
                        Icons.check_circle,
                        size: 28,
                        color: Color(int.parse(
                            "0xff" + listColorC[index].replaceAll("#", ""))),
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
}
