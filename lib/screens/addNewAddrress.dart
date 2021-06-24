import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/home.dart';

import 'package:lottie/lottie.dart';

import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'myOrders.dart';

class AddNewAddress extends StatefulWidget {
  String isCash;
  String from;
  String lat;
  String lon;
  Map address;
  Address addrMap;
  final double grandTotal;
  final double couponDiscount;
  String productname;
  String packageid,type,method;

  AddNewAddress(String isCash, Map address, String from, String lat, String lon,
      Address addrMap, this.grandTotal, this.couponDiscount, this.productname,String packageid,String type,String method) {
    this.isCash = isCash;
    this.from = from;
    this.address = address;
    this.lat = lat;
    this.lon = lon;
    this.addrMap = addrMap;
    this.productname = productname;
    this.method = method;
    this.packageid = packageid;
    this.type = type;
  }

  @override
  _AddNewAddress createState() =>
      _AddNewAddress(isCash, address, from, lat, lon, addrMap);
}

class _AddNewAddress extends State<AddNewAddress> {
  static const platform = const MethodChannel("razorpay_flutter");

  Razorpay _razorpay;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool serviceAvailable = false;
  bool pinchecked = false;
  Map user;
  Map address;
  String isCash = "";
  String from = "";
  String lattitude = "";
  String longitude = "";
  Address addrMap;
  TextEditingController customer_name = new TextEditingController();
  TextEditingController phone_number = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController flat_house = new TextEditingController();
  TextEditingController street_colony = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController pin = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController country = new TextEditingController();

  _AddNewAddress(String isCash, Map address, String from, String lat,
      String lon, Address addrMap) {
    this.from = from;
    this.isCash = isCash;
    this.address = address;
    this.lattitude = lat;
    this.longitude = lon;
    this.addrMap = addrMap;
    if (addrMap != null) {
      if (address != null) {
        customer_name.text = address['customer_name'];
        phone_number.text = address['customer_phone'];
        email.text = address['customer_email'];
        if (address['lat'] == lat) {
          flat_house.text =
              address['customer_address'].toString().split(", ")[0];
          street_colony.text =
              address['customer_address'].toString().split(", ")[1];
          pin.text = address['customer_pincode'];
        } else {
          flat_house.text =
              addrMap.subThoroughfare != null ? addrMap.subThoroughfare : "";
          street_colony.text =
              addrMap.thoroughfare != null ? addrMap.thoroughfare : "";
          pin.text = addrMap.postalCode != null ? addrMap.postalCode : "";
        }
      } else {
        flat_house.text =
            addrMap.subThoroughfare != null ? addrMap.subThoroughfare : "";
        street_colony.text =
            addrMap.thoroughfare != null ? addrMap.thoroughfare : "";
        pin.text = addrMap.postalCode != null ? addrMap.postalCode : "";
      }
      country.text = addrMap.countryName;
      city.text = addrMap.locality != null ? addrMap.locality : "";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_live_sVfDW604UOYc6p',
      'amount': widget.grandTotal * 100,
      'name': 'Littardo',
      'description': widget.productname,
      'prefill': {'contact': phone_number.text, 'email': email.text},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(response.paymentId);
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIosWeb: 4);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    getProgressDialog(context, "Placing Order...").hide(context);
    Fluttertoast.showToast(
        msg: "ERROR: " + response.message, timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // if(response.)
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        SafeArea(
            child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blue,
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => {Navigator.of(context).pop()}),
            title: Text(
              "Add New Address",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              color: Colors.blue,
              height: 50.0,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new GestureDetector(
                      onTap: () {
                        if (customer_name.text == "") {
                          presentToast('Enter CUSTOMER NAME', context, 0);
                        } else if (phone_number.text.length < 10) {
                          presentToast('Enter valid PHONE NUMBER', context, 0);
                        } else if (!validateEmail(email.text)) {
                          presentToast('Enter valid EMAIL', context, 0);
                        } else if (flat_house.text == "") {
                          presentToast(
                              'Enter FLAT/HOUSE NO./BUILDING', context, 0);
                        } else if (street_colony.text == "") {
                          presentToast('Enter STREET/COLONY', context, 0);
                        } else if (pin.text == "") {
                          presentToast('Enter PINCODE', context, 0);
                        } else if (city.text == "") {
                          presentToast('Enter CITY', context, 0);
                        } else if (pinchecked && !serviceAvailable) {
                          presentToast('Service to this PINCODE not available',
                              context, 0);
                        } else if (country.text == "") {
                          presentToast('Enter COUNTRY', context, 0);
                        } else if (widget.method=="" && isCash == "") {
                          presentToast('Select mode of payment', context, 0);
                        } else {
                          addAddress();
                        }
                      },
                      child: Text(widget.method!=""?"SUBSCRIBE":"SAVE & PLACE ORDER",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Colors.white))),
                ],
              ),
            ),
          ),
          body: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      "CUSTOMER NAME",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left, // has impact
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      child: TextField(
                          controller: customer_name,
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 11))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: new Text(
                        "PHONE NUMBER",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left, // has impact
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      child: TextField(
                          controller: phone_number,
                          maxLength: 11,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 11))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: new Text(
                        "EMAIL",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left, // has impact
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      child: TextField(
                          controller: email,
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 11))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: new Text(
                        "FLAT/HOUSE NO./BUILDING",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left, // has impact
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      child: TextField(
                          controller: flat_house,
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 11))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: new Text(
                        "STREET/COLONY",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left, // has impact
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      child: TextField(
                          controller: street_colony,
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 11))),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 2.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    "PINCODE",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.left, // has impact
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 18,
                                    child: TextField(
                                        controller: pin,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        onChanged: (String text) {},
                                        decoration: InputDecoration(
                                            counterStyle: TextStyle(
                                              height: double.minPositive,
                                            ),
                                            counterText: "",
                                            hintText: "",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11))),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 14),
                                    child: new Text(
                                      "COUNTRY",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.left, // has impact
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 18,
                                    child: TextField(
                                        enabled:
                                            country.text == "" ? true : false,
                                        controller: country,
                                        decoration: InputDecoration(
                                            hintText: "",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11))),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 2.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    "CITY",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.left, // has impact
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 18,
                                    child: TextField(
                                        enabled: city.text == "" ? true : false,
                                        controller: city,
                                        decoration: InputDecoration(
                                            hintText: "",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11))),
                                  ),
//                                  Padding(
//                                    padding: EdgeInsets.only(top: 14),
//                                    child: new Text(
//                                      "STATE",
//                                      style: TextStyle(
//                                        color: Colors.grey,
//                                        fontSize: 12,
//                                        decoration: TextDecoration.none,
//                                      ),
//                                      textAlign: TextAlign.left, // has impact
//                                    ),
//                                  ),
//                                  Container(
//                                    width: MediaQuery.of(context).size.width,
//                                    height:
//                                        MediaQuery.of(context).size.height / 18,
//                                    child: TextField(
//                                        controller: state,
//                                        decoration: InputDecoration(
//                                            hintText: "",
//                                            hintStyle: TextStyle(
//                                                color: Colors.grey,
//                                                fontSize: 11))),
//                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              )),
        )),
      ],
    );
  }

  bool validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
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

  placeOrder(String paymentId) {
    print(Uri.parse(
        widget.method!=""?api_url + widget.method:from == "Checkout" ? api_url + "order?buy" : api_url + "order"));
    var request = new MultipartRequest(
        "POST",
        Uri.parse(
            from == "Checkout" ? api_url + "order?buy" : api_url + "order"));
            if(widget.method!=""){
               request.fields["payment_id"] = paymentId;
    request.fields["package_id"] = widget.packageid;
    request.fields["type"] = widget.type;
            }
    request.fields["customer_name"] = customer_name.text;
    request.fields["customer_email"] = email.text;
    request.fields["customer_address"] =
        flat_house.text + ", " + street_colony.text;
    request.fields["customer_country"] = country.text;
    request.fields["customer_city"] = city.text;
    request.fields["customer_pincode"] = pin.text;
    request.fields["customer_phone"] = phone_number.text.length<11?"0${phone_number.text}":phone_number.text;
    request.fields["payment_option"] =
        isCash == "cash_on_delivery" ? isCash : "razorpay";
    request.fields["lat"] = lattitude;
    request.fields["lon"] = longitude;
    request.fields["coupon_discount"] = widget.couponDiscount.toString();
    request.fields["wallet_discount"] = Provider.of<UserData>(context,listen: false).userData['balance'];
    request.fields["grand_total"] = widget.grandTotal.toString();
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/json";
    request.headers["APP"] = "ECOM";
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data.toString() + "===");
        if (data['code'] == 200) {
          Provider.of<UserData>(context, listen: false).saveCartCount(0);
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => MyOrders()));
        } else {
          presentToast(data['message'], context, 0);
          getProgressDialog(context, "Placing Order...").hide(context);
        }
      });
    });
  }

//  void checkPinCode(String pin) {
//    setState(() {
//      _isLoading = true;
//      pinchecked = true;
//    });
//    commeonMethod2(api_url + "app/checkServiceAvailability?pincode=" + pin,
//            accessToken)
//        .then((onResponse) async {
//      Map data = json.decode(onResponse.body);
//      print(data);
//      if (data['code'] == 200) {
//        setState(() {
//          _isLoading = false;
//          serviceAvailable = true;
//            state.text = data['data']['state'];
//            country.text = "INDIA";
//            city.text = data['data']['city'];
//        });
//      } else {
//        setState(() {
//          serviceAvailable = false;
//          _isLoading = false;
//        });
//        presentToast(data['message'], context, 0);
//      }
//    });
//  }

//  void getPinCodeData(String pin) {
//    setState(() {
//      _isLoading = true;
//      pinchecked = true;
//    });
//    commeonMethod2("https://api.postalpincode.in/pincode/" + pin,
//            accessToken)
//        .then((onResponse) async {
//      List data = json.decode(onResponse.body);
//      print(data);
//      if (data[0]['Status'] == 'Success') {
//        setState(() {
//          state.text = data[0]['PostOffice'][0]['State'];
//          country.text = data[0]['PostOffice'][0]['Country'];
//        });
//        checkPinCode(pin);
//      } else {
//        setState(() {
//          serviceAvailable = false;
//          _isLoading = false;
//        });
//        presentToast(data[0]['Message'], context, 0);
//      }
//    });
//  }

//  void proceedToPayment(String order_id) {
//    commeonMethod2(
//            api_url + "payment/createLink?order_id=" + order_id, accessToken)
//        .then((onResponse) async {
//      Map data = json.decode(onResponse.body);
//      if (data['status'] == "OK") {
//        setState(() {
//          _isLoading = false;
//        });
//        Navigator.of(context)
//            .push(MaterialPageRoute(
//                builder: (context) => WebViewPage(data['paymentLink'])))
//            .then((onVal) async {
//          SharedPreferences prefs = await SharedPreferences.getInstance();
//          if (onVal == "https://secureapi.littardo.com/payment/complete") {
//            prefs.setString("cartCount", null);
//            Navigator.pushAndRemoveUntil(
//              context,
//              new MaterialPageRoute(builder: (context) => new HomePage()),
//              (Route<dynamic> route) => false,
//            );
//          }
////            showThankYouBottomSheet(
////                context, order_id, "Payment Sucessful", "success");
//        });
//      } else {
//        setState(() {
//          _isLoading = false;
//        });
//        presentToast(data['message'], context, 0);
//      }
//    });
//  }

  showThankYouBottomSheet(
      BuildContext context, String message1, String message2, String status) {
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
                        text: TextSpan(
                            text: "#" + message1,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: "\n\n" + message2,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade800),
                              )
                            ])),
                    SizedBox(
                      height: 24,
                    ),
                    RaisedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        if (status == "success") {
                          prefs.setString("cartCount", null);
                          Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Home()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
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

  void addAddress() {
    getProgressDialog(context, "Placing Order...").show();
    var request = new MultipartRequest(
        "POST",
        Uri.parse(address != null
            ? api_url + "addresses/update"
            : api_url + "addresses"));
    if (address != null) {
      request.fields["address_id"] = address['id'].toString();
    }
    request.fields["customer_name"] = customer_name.text;
    request.fields["customer_email"] = email.text;
    request.fields["customer_address"] =
        flat_house.text + ", " + street_colony.text;
    request.fields["customer_country"] = country.text;
    request.fields["customer_city"] = city.text;
    request.fields["customer_pincode"] = pin.text;
    request.fields["customer_phone"] = phone_number.text;
    request.fields["lat"] = lattitude;
    request.fields["lon"] = longitude;
    request.headers['Authorization'] = "Bearer " +
        Provider.of<UserData>(context, listen: false).userData['api_token'];
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/json";
    request.headers["APP"] = "ECOM";
    print(request);
    print(request.headers);
    print(request.fields);
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          print(isCash);
          if (isCash == "cash_on_delivery") {
            placeOrder("");
          } else {
            openCheckout();
          }
          // placeOrder();
        } else {
          presentToast(data['message'], context, 0);
          getProgressDialog(context, "Placing Order...").hide(context);
        }
      });
    });
  }
}
