import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  _OrderDetais(Map product) {
    this.product = product;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, showReview);
      },
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {Navigator.pop(context, showReview)}),
          title: Text(
            "Order Detail",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        new Flexible(
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, right: 10),
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
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          flex: 8,
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
                                      "Ordered On - " + product['created_at'],
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: InkWell(
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
                                      fit: BoxFit.fill)),
                            ),
                          ),
                        ),
                      ],
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
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                                textAlign: TextAlign
                                                    .start, // has impact
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
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                                textAlign: TextAlign
                                                    .start, // has impact
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
                    SizedBox(
                      height: 10,
                    )
                  ],
                )),
            SizedBox(
              height: 8,
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
            Container(
                color: Colors.white,
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
        )),
      )),
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
