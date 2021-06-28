import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icons/ionicons.dart';
import 'package:http/http.dart';
import 'package:littardo/widgets/submitbutton.dart';
import 'package:provider/provider.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/add_location.dart';
import 'package:littardo/services/api_services.dart';

class Checkout extends StatefulWidget {
  final String isCash;
  final String from;
  final double grandTotal;
  final double couponDiscount;
  final String productname;
  Checkout(
      {this.isCash,
      this.from,
      this.grandTotal,
      this.couponDiscount,
      this.productname});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  List addresses = new List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("iscash" + widget.isCash);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon:
              Icon(Ionicons.getIconData("ios-arrow-back"), color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding:
              EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 12.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 6.0,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Delivery Adress"),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddLocation(
                                      widget.isCash,
                                      addresses[index],
                                      widget.from,
                                      widget.grandTotal,
                                      widget.couponDiscount,
                                      widget.productname,"","","")));
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 12.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                color: Color(0xFFE7F9F5),
                                border: Border.all(
                                  color: Color(0xFF4CD7A5),
                                ),
                              ),
                              child: ListTile(
                                trailing: InkWell(
                                  onTap: () {
                                    deleteAddress(
                                        addresses[index]['id'].toString());
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                title:
                                    Text(addresses[index]['customer_address']),
                                subtitle: Text(addresses[index]
                                        ['customer_city'] +
                                    " - " +
                                    addresses[index]['customer_pincode'] +
                                    ", " +
                                    addresses[index]['customer_country']),
                              ),
                            ),
                          );
                        }),
                    SubmitButton(
                      title: "Add New Address",
                      act: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddLocation(
                                widget.isCash,
                                null,
                                widget.from,
                                widget.grandTotal,
                                widget.couponDiscount,
                                widget.productname,"","","")))
                      } ,
                    ),
                    // Text("Payment method"),
                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 12.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //     color: Color(0xFFF5F8FB),
                    //   ),
                    //   child: ListTile(
                    //     leading: Icon(
                    //       Icons.email,
                    //       color: Colors.black54,
                    //     ),
                    //     title: Text('test@gmail.com'),
                    //   ),
                    // ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 12.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //     color: Color(0xFFE7F9F5),
                    //     border: Border.all(
                    //       color: Color(0xFF4CD7A5),
                    //     ),
                    //   ),
                    //   child: ListTile(
                    //     trailing: Icon(
                    //       Icons.check_circle,
                    //       color: Color(0xFF10CA88),
                    //     ),
                    //     leading: Icon(
                    //       Icons.credit_card,
                    //       color: Color(0xFF10CA88),
                    //     ),
                    //     title: Text('**** **** 2222 4444'),
                    //   ),
                    // ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 12.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //     color: Color(0xFFF5F8FB),
                    //   ),
                    //   child: ListTile(
                    //     leading: Icon(
                    //       Icons.card_membership,
                    //       color: Colors.black54,
                    //     ),
                    //     title: Text('**** **** 1111 2222'),
                    //   ),
                    // ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 24.0),
                    //   child: FlatButton(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(4.0),
                    //     ),
                    //     color: Color(0xFFF93963),
                    //     onPressed: () => {
                    //       showDialog(
                    //         context: context,
                    //         // ignore: deprecated_member_use
                    //         child: AlertDialog(
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius:
                    //                   BorderRadius.all(Radius.circular(16.0))),
                    //           content: Container(
                    //             height:
                    //                 MediaQuery.of(context).size.height / 1.8,
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: <Widget>[
                    //                 Icon(
                    //                   Icons.check_circle_outline,
                    //                   size: 96,
                    //                   color: Color(0xFF10CA88),
                    //                 ),
                    //                 Padding(
                    //                   padding: const EdgeInsets.symmetric(
                    //                       vertical: 16.0),
                    //                   child: Text(
                    //                     "Your order successfull",
                    //                     style: TextStyle(fontSize: 20),
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding: const EdgeInsets.symmetric(
                    //                       vertical: 16.0),
                    //                   child: Text(
                    //                     "Your can track the delivery in the Orders section ",
                    //                     style: TextStyle(fontSize: 16),
                    //                   ),
                    //                 ),
                    //                 FlatButton(
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(4.0),
                    //                   ),
                    //                   color: Color(0xFFF93963),
                    //                   onPressed: () => {},
                    //                   child: Container(
                    //                     padding: EdgeInsets.symmetric(
                    //                       vertical: 15.0,
                    //                       horizontal: 10.0,
                    //                     ),
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: <Widget>[
                    //                         Expanded(
                    //                           child: InkWell(
                    //                             onTap: () {
                    //                               Nav.route(context, Home());
                    //                             },
                    //                             child: Text(
                    //                               "Continue Shopping",
                    //                               textAlign: TextAlign.center,
                    //                               style: TextStyle(
                    //                                   color: Colors.white,
                    //                                   fontWeight:
                    //                                       FontWeight.bold),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 FlatButton(
                    //                   child: Text("Go to orders"),
                    //                   onPressed: () {},
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     },
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(
                    //         vertical: 15.0,
                    //         horizontal: 10.0,
                    //       ),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Expanded(
                    //             child: Text(
                    //               "Payment",
                    //               textAlign: TextAlign.center,
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontWeight: FontWeight.bold),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getAddresses() {
    getProgressDialog(context, "Fetching address...").show();
    commeonMethod2(api_url + "addresses",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      print(data);
      if (data['code'] == 200) {
        setState(() {
          addresses = data['data'];
        });
      } else {
        presentToast(data['message'], context, 0);
      }
      getProgressDialog(context, "Fetching address...").hide(context);
    }).catchError((onerr) {
      getProgressDialog(context, "Fetching address...").hide(context);
    });
  }

  void deleteAddress(String id) {
    getProgressDialog(context, "Deleting address...").show();
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "addresses/delete"));
    request.fields["address_id"] = id;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/json";
    request.headers["APP"] = "ECOM";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          getAddresses();
        }
        getProgressDialog(context, "Deleting address...").hide(context);
      });
    });
  }
}
