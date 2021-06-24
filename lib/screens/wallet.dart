import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intent/extra.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/screens/transaction.dart';
import 'package:littardo/widgets/dashed.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyWallet extends StatefulWidget {
  _MyWallet createState() => _MyWallet();
}

class _MyWallet extends State<MyWallet> {
  static const platform = const MethodChannel("razorpay_flutter");

  Razorpay _razorpay;
   double money = 50.00;
  List<Color> _backgroundColor;
  Color _iconColor;
  Color _textColor;
  List<Color> _actionContainerColor;
  Color _borderContainer;
  bool colorSwitched = false;
  var logoImage;
  List wishListData = new List();
  bool serviceCalled = false;

  void changeTheme() async {
    if (colorSwitched) {
      setState(() {
        logoImage = 'assets/wallet_dark_logo.png';
        _backgroundColor = [
          Color.fromRGBO(252, 214, 0, 1),
          Color.fromRGBO(251, 207, 6, 1),
          Color.fromRGBO(250, 197, 16, 1),
          Color.fromRGBO(249, 161, 28, 1),
        ];
        _iconColor = Colors.white;
        _textColor = Color.fromRGBO(253, 211, 4, 1);
        _borderContainer = Color.fromRGBO(34, 58, 90, 0.2);
        _actionContainerColor = [
          Color.fromRGBO(47, 75, 110, 1),
          Color.fromRGBO(43, 71, 105, 1),
          Color.fromRGBO(39, 64, 97, 1),
          Color.fromRGBO(34, 58, 90, 1),
        ];
      });
    } else {
      setState(() {
        logoImage = 'assets/wallet_logo.png';
        _borderContainer = Color.fromRGBO(252, 233, 187, 1);
        _backgroundColor = [
          Color.fromRGBO(249, 249, 249, 1),
          Color.fromRGBO(241, 241, 241, 1),
          Color.fromRGBO(233, 233, 233, 1),
          Color.fromRGBO(222, 222, 222, 1),
        ];
        _iconColor = Colors.black;
        _textColor = Colors.black;
        _actionContainerColor = [
          Color.fromRGBO(255, 212, 61, 1),
          Color.fromRGBO(255, 212, 55, 1),
          Color.fromRGBO(255, 211, 48, 1),
          Color.fromRGBO(255, 211, 43, 1),
        ];
      });
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black))
          ],
        ),
      ),
    );
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
      'amount': money * 100,
      'name': 'Littardo',
      'description': "Add to Wallet",
      'prefill': {'contact': Provider.of<UserData>(context, listen: false)
                                .userData['phone'], 'email': Provider.of<UserData>(context, listen: false)
                                .userData['email']},
      'external': {
        'wallets': ['paytm']
      }
    };

    print(options);

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
    if (Theme.of(context).brightness == Brightness.dark) {
      colorSwitched = true;
    } else {
      colorSwitched = false;
    }
    changeTheme();
    return Material(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Scaffold(
              body: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.2, 0.3, 0.5, 0.8],
                          colors: _backgroundColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Image.asset(
                        logoImage,
                        fit: BoxFit.contain,
                        height: 100.0,
                        width: 100.0,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Hello',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Text(
                            Provider.of<UserData>(context, listen: false)
                                .userData['name'],
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Container(
                        height: 300.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: _borderContainer,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0.2, 0.4, 0.6, 0.8],
                                    colors: _actionContainerColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 70,
                                  child: Center(
                                    child: ListView(
                                      children: <Widget>[
                                        Text(
                                          '\u20b9 ' +
                                              Provider.of<UserData>(context,
                                                      listen: false)
                                                  .userData['balance'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: _textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30),
                                        ),
                                        Text(
                                          'Available Cash',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: _iconColor, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 0.5,
                                  color: Colors.grey,
                                ),
                                Table(
                                  border: TableBorder.symmetric(
                                    inside: BorderSide(
                                        color: Colors.grey,
                                        style: BorderStyle.solid,
                                        width: 0.5),
                                  ),
                                  children: [
                                    TableRow(children: [
                                      // _actionList(
                                      //     'assets/ic_send.png', 'Send Money'),
                                      _actionList(
                                          'assets/ic_money.png', 'Add Money'),
                                           _actionList('assets/ic_transact.png',
                                          'Transactions'),
                                    ]),
                                    // TableRow(children: [
                                    //   _actionList('assets/ic_transact.png',
                                    //       'Transactions'),
                                    //   _actionList('assets/ic_reward.png',
                                    //       'Reward Points'),
                                    // ])
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            _backButton(),
            Positioned(
              right: 0,
              child: RaisedButton(
                onPressed: () {
                  _bottomsheet();
                },
                color: Colors.red,
                textColor: Colors.white,
                child: Text("Refer & Earn".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(20)),
                    side: BorderSide(color: Colors.red)),
              ),
            )
          ],
        ),
      ),
    );
  }

  _bottomsheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Stack(
            children: <Widget>[
              Container(
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(50.0),
                          topRight: const Radius.circular(50.0))),
                  child: new Center(
                      child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 20, bottom: 5),
                        child: Image.asset('assets/refer.png',
                            height: MediaQuery.of(context).size.height * 0.1),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 5),
                          child: Provider.of<UserData>(context, listen: false)
                                      .referralCode !=
                                  ""
                              ? DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: Colors.grey[300],
                                  radius: Radius.circular(12),
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text('Referral Code',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              ),
                                              SizedBox(height: 5),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    Provider.of<UserData>(
                                                            context,
                                                            listen: false)
                                                        .referralCode,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.grey[300],
//                        height: MediaQuery.of(context).size.height/18,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16, bottom: 16),
                                                  child: Text(
                                                      'SHARE NOW & START EARNING',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.blue)),
                                                ),
                                              )
                                            ],
                                          ))),
                                )
                              : RaisedButton(
                                  onPressed: () {
                                    generateReferralCode();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('GET REFERRAL CODE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.blue)),
                                )),
                      Padding(
                        padding: EdgeInsets.only(top: 25, bottom: 10),
                        child: Center(
                          child: Text('OR',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 30),
                          child: Center(
                            child: Text('Invite by Sharing on',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                          )),
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              var content =
                                  "Join me and 1 Lakh+ people who are earning money from home using Littardo App.\n" +
                                      "\n" +
                                      "*Use referral code: " +
                                      Provider.of<UserData>(context,
                                              listen: false)
                                          .referralCode +
                                      "*\n" +
                                      "\n" +
                                      "Get *Rs.250/-* when you download the app and Rs.5250/- when you place your first order.\n\nAnd this *Rs.5250/-* should be credited once the product is delivered and return cycle is over";
                              var whatsappUrl =
                                  "whatsapp://send?text=${content}";
                              await canLaunch(whatsappUrl)
                                  ? launch(whatsappUrl)
                                  : launch(
                                      "https://play.google.com/store/apps/details?id=com.whatsapp&hl=en");
                            },
                            child: Container(
                                height: MediaQuery.of(context).size.height / 14,
                                child: ClipRRect(
                                    child: Image(
                                        image:
                                            AssetImage('assets/whatsapp.png'),
                                        fit: BoxFit.fill))),
                          ),
                          GestureDetector(
                            onTap: () async {
                              var content =
                                  "Join me and 1 Lakh+ people who are earning money from home using Littardo App.\n" +
                                      "\n" +
                                      "*Use referral code: " +
                                      Provider.of<UserData>(context,
                                              listen: false)
                                          .referralCode +
                                      "*\n" +
                                      "\n" +
                                      "Get *Rs.250/-* when you download the app and Rs.5250/- when you place your first order.\n\nAnd this *Rs.5250/-* should be credited once the product is delivered and return cycle is over";
//                                          "\n" +
//                                          "\n"
//                                          "Download Now - https://play.google.com/store/apps/details?id=com.enrichtechnosoft.littardo&hl=en";
                              var whatsappUrl =
                                  "fb-messenger://share?link=${content}";
                              await canLaunch(whatsappUrl)
                                  ? launch(whatsappUrl).catchError((err) {
                                      print(err);
                                    })
                                  : launch(
                                      "https://play.google.com/store/apps/details?id=com.facebook.orca&hl=en");
                            },
                            child: Container(
                                height: MediaQuery.of(context).size.height / 14,
                                child: ClipRRect(
                                    child: Image(
                                        image:
                                            AssetImage('assets/facebook.png'),
                                        fit: BoxFit.fill))),
                          ),
                          InkWell(
                            onTap: () async {
                              var content =
                                  "Join me and 1 Lakh+ people who are earning money from home using Littardo App.\n" +
                                      "\n" +
                                      "*Use referral code: " +
                                      Provider.of<UserData>(context,
                                              listen: false)
                                          .referralCode +
                                      "*\n" +
                                      "\n" +
                                      "Get *Rs.250/-* when you download the app and Rs.5250/- when you place your first order.\n\nAnd this *Rs.5250/-* should be credited once the product is delivered and return cycle is over";
                              android_intent.Intent()
                                ..setAction(android_action.Action.ACTION_SEND)
                                ..setType('text/plain')
                                ..putExtra(Extra.EXTRA_PACKAGE_NAME,
                                    'com.instagram.android')
                                ..putExtra(Extra.EXTRA_TEXT, content)
                                ..startActivity().catchError((e) => print(e));
                            },
                            child: Container(
                                height: MediaQuery.of(context).size.height / 14,
                                child: ClipRRect(
                                    child: Image(
                                        image:
                                            AssetImage('assets/instagram.png'),
                                        fit: BoxFit.fill))),
                          )
                        ],
                      )),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ))),
            ],
          );
        });
  }
void _settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return StatefulBuilder(
                      builder: (context, setState) {
                       return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
              ),
              child: new Wrap(
                children: <Widget>[

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center
                    ,children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                  backgroundImage: AssetImage("assets/user.png"),
                ),
                    ),
                  ],),
              Container(
                alignment: Alignment.center,
                child: Text(Provider.of<UserData>(context, listen: false)
                                .userData['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),),
              ),
                  Container(
                    alignment: Alignment.center,
                    child: Text("Amount to add"),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                            onTap: (){
                              if(money > 59){
                                setState((){
                                  money -= 10;
                                });
                              }
                            },
                            child: CircleAvatar(child: Icon(Icons.remove, color: Colors.white,), radius: 20, backgroundColor: Colors.grey,)),
                      ),
                      SizedBox(width: 10,),
                      Text("$money", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold ),),
                      SizedBox(width: 10,),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              money += 10;
                            });
                          },
                            child: CircleAvatar(child: Icon(Icons.add, color: Colors.white,), radius: 20, backgroundColor: Colors.grey,)),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                        openCheckout();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xff60282e),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text("Add Money", style: TextStyle(fontSize: 22, color: Colors.white),),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          
                      },);
        }
    );
  }
// custom action widget
  Widget _actionList(String iconPath, String desc) {
    return GestureDetector(
      onTap: (){
        if(desc == "Add Money"){
_settingModalBottomSheet(context);
        }else{
         Navigator.push(
              context, MaterialPageRoute(builder: (_) => Transactions()));
        }
      },
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              iconPath,
              fit: BoxFit.contain,
              height: 45.0,
              width: 45.0,
              color: _iconColor,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              desc,
              style: TextStyle(color: _iconColor),
            )
          ],
        ),
      ),
    );
  }

  
placeOrder(paymentId) {
    var request = new MultipartRequest(
        "POST",
        Uri.parse(api_url + "wallet-balance"));
    request.fields["payment_id"] = paymentId.toString();
    request.fields["balance"] = money.toString();
    
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
          Provider.of<UserData>(context, listen: false).saveWalletBalance(data['data']['balance']);
          Navigator.of(context).pop();
          
        } else {
          presentToast(data['message'], context, 0);
          getProgressDialog(context, "Placing Order...").hide(context);
        }
      });
    });
  }
  generateReferralCode() {
    commeonMethod2(api_url + "generate_referral_code",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) async {
      Map data = json.decode(onResponse.body);
      print(data);
      presentToast(data['message'], context, 0);
      if (data['code'] == 200) {
        Provider.of<UserData>(context, listen: false)
            .updateReferalCode(data['user']['referral_code']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("referral_code", data['user']['referral_code']);
        getProgressDialog(context, "Generating code...").hide(context);
      }
    });
  }
}
