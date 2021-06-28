import 'dart:convert';
import 'dart:math';

import 'package:littardo/models/subscription.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/controlled_animation.dart';
import 'package:littardo/utils/multi_track_tween.dart';
import 'package:littardo/widgets/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/widgets/submitbutton.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'add_location.dart';

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Theme.of(context).primaryColor, end: Theme.of(context).primaryColor.withOpacity(0.9))),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Theme.of(context).primaryColor, end: Theme.of(context).primaryColor.withOpacity(0.6)))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class SubscriptionPlans extends StatefulWidget {
  String id, name;
  SubscriptionPlans(String id, String name){
    this.id = id;
    this.name = name;
  }

  
  _SubscriptionPlansState createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<SubscriptionPlans>
    with SingleTickerProviderStateMixin {
  List<Subription> subcriptionList = new List();
  String acccessToken = "";
  bool _isLoading = false;
  String selectedpackage_id = "";
  String selectedtype = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List addresses = new List();
  List child = new List();

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  //Manually operated Carousel
  CarouselSlider manualCarouselDemo;

  bool serviceCalled = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getSubscription();
    getAddresses();
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: _buildWidget(),
      ),
    );
  }

placeOrder(paymentId) {

    var request = new MultipartRequest(
        "POST",
        Uri.parse(api_url + "subscribe-package"));
    request.fields["payment_id"] = paymentId.toString();
    request.fields["package_id"] = selectedpackage_id;
    request.fields["type"] = selectedtype;
    
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
          getProgressDialog(context, "Placing Order...").hide(context);
          
        } else {
          presentToast(data['message'], context, 0);
          getProgressDialog(context, "Placing Order...").hide(context);
        }
      });
    });
  }

  getSubscription() {
    getProgressDialog(context, "Please wait...").show();
    commeonMethod2(api_url + "subscription-packages?category_id=${widget.id}",
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
         List<Subription> tempList = new List();
         if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                
                tempList.add(new Subription(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['title'],
                    data['data'][i]['description'],
                    data['data'][i]['amount'],
                    data['data'][i]['type'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at']));
              }
              setState(() {
                subcriptionList = tempList;
              });
              setSubscriptionData();
            }
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Please wait...").hide(context);
    });
  }

  _displaySnackBar(msg) {
    final snackBar = new SnackBar(
      content: Text(msg),
      backgroundColor: Colors.black,
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    var backGround = Positioned.fill(child: AnimatedBackground());
    list.add(backGround);
    var animate1 = onBottom(AnimatedWave(
      height: 180,
      speed: 1.0,
    ));
    list.add(animate1);
    var animate2 = onBottom(AnimatedWave(
      height: 120,
      speed: 0.9,
      offset: pi,
    ));
    list.add(animate2);

    var amimate3 = onBottom(AnimatedWave(
      height: 220,
      speed: 1.2,
      offset: pi / 2,
    ));
    list.add(amimate3);
    var mainView = SafeArea(child: Column(children: [
      Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            color: Colors.white,
          ),
          Text(
            "Subscription Plans \n(${widget.name})",
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
      Expanded(
        child: (child.length > 0)
            ? manualCarouselDemo
            : SizedBox(
                height: 10,
              ),
      ),
    ]));
    if (subcriptionList.length > 0) {
      list.add(mainView);
    }
   
    return list;
  }

  void setSubscriptionData() {
    setState(() {
      child = map<Widget>(
        subcriptionList,
        (index, item) {
          print(item.description);
          return Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Column(children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  width: 400,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(item.title),
                      SizedBox(
                        height: 20,
                      ),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              text: "\u20b9 ",
                              children: <TextSpan>[
                            TextSpan(
                                text: item.amount,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold)),
                                // TextSpan(
                                //     text: "/" + item.validity+" days",
                                //     style: TextStyle(color: Colors.black))
                          ]))
                    ],
                  ),
                ),
                Container(
                  width: 400,
                  color: Colors.white30,
                  child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.description),
                      ),
                ),
              Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, minHeight: 45.0),
                        child: RaisedButton(
                            child: new Text("Subscribe"),
                            onPressed: () {
                              setState(() {
                                selectedpackage_id = item.id;
                                selectedtype = item.type;
                              });
                              return 
               showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Delivery Address'),
          
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddLocation(
                                  "",
                                  addresses[index],
                                  "",
                                  double.parse(item.amount),
                                  0,
                                  "",selectedpackage_id,selectedtype,"subscribe-package")));
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
                    
                        Navigator.pop(context),
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddLocation(
                            "",
                            null,
                            "",
                            double.parse(item.amount),
                            0,
                            "",selectedpackage_id,selectedtype,"subscribe-package")))
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
                              // openCheckout(double.parse(item.amount));
                            },
                            textColor: Colors.white,
                            color: Color(0xFF3c3790),
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    new BorderRadius.circular(30.0)))),
                  ),
                ),
              ]),
            ),
          );
        },
      ).toList();

      manualCarouselDemo = CarouselSlider(
        items: child,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        aspectRatio: 1.0,
        initialPage: 1,
      );
    });
  }
}
