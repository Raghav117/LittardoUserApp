import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:littardo/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Review extends StatefulWidget {
  Map product;
  double rating;
  Review(Map product,double rating) {
    this.product = product;
    this.rating = rating;
  }

  _Review createState() => _Review(product,rating);
}

class _Review extends State<Review> {
  Map product;
  bool _isLoading = false;
  String accessToken = "";
  TextEditingController review = new TextEditingController();
  double rating;
  _Review(Map product, double rating) {
    this.product = product;
    this.rating = rating;
    print(product);
  }

  Map user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSavedData();
  }

  Future<void> checkSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = jsonDecode(prefs.getString("user"));
    accessToken = user['api_token'];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(
              "Review",
            ),
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => {Navigator.pop(context)}),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 4,
                        child: ClipRRect(
                            child: CachedNetworkImage(
                                imageUrl: product['product']
                                    ['thumbnail_img'],
                                height: 120,
                                width: 100,
                                fit: BoxFit.fill)),
                      ),
                      Flexible(
                        flex: 8,
                        child: Wrap(
                          direction: Axis.vertical,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['product']
                                    ['name'],
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RatingBar(
                                initialRating: rating,
                                minRating: 0.5,
                                itemSize: 15,
                                direction: Axis.horizontal,
                                ignoreGestures: true,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.blue[900],
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                  child: new TextFormField(
                    controller: review,
                    maxLines: 5,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      counterStyle: TextStyle(
                        height: double.minPositive,
                      ),
                      counterText: "",
                      alignLabelWithHint: true,
                      labelText: "Write your review",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 40, 8, 40),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          minWidth: double.infinity, minHeight: 45.0),
                      child: RaisedButton(
                          child: new Text("Submit Review"),
                          onPressed: () {
                            if (review.text == "") {
                              presentToast('Write your review', context, 0);
                            } else {
                              submitReview();
                            }
                          },
                          textColor: Colors.white,
                          color: Colors.blue,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)))),
                ),
              ],
            ),
          ),
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

  void submitReview() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "POST",
        Uri.parse(api_url+"products/add_review"));
    request.fields["rating"] = rating.toString();
    request.fields["comment"] = review.text;
    request.fields["product_id"] = product['product']['id'].toString();
    request.headers['Authorization'] = "Bearer " + user['api_token'];
    request.headers['Accept'] = "application/json";
    request.headers['Content-Type'] = "application/json";
    request.headers["APP"] = "ECOM";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) async {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          Navigator.pop(context, "success");
        }
      });
    });
  }
}
