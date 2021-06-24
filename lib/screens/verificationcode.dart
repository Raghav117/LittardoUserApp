import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/codeinput.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'forgetpassword.dart';
import 'package:littardo/utils/progressdialog.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String user_id;

  VerificationScreen({this.phoneNumber, this.user_id});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, ProgressDialogType.Normal);
    pr.setMessage('Verifying account...');
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 96.0),
            child: Column(
              children: <Widget>[
                Image.asset(
          "assets/littardo_logo.jpg",
          height: 80,
          width: 80,
        ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("Phone Verification",
                      style: Theme.of(context).textTheme.title),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 48.0),
                  child: Text(
                    "Enter your code here",
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                FittedBox(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    padding: EdgeInsets.only(bottom: 64.0),
                    child: CodeInput(
                      length: 6,
                      keyboardType: TextInputType.number,
                      builder: CodeInputBuilders.darkCircle(),
                      onFilled: (value) async {
                        print('Your input is $value.');
                        pr.show();
                        var request = MultipartRequest(
                            "POST", Uri.parse(api_url + "verify_otp"));
                        request.fields['phone'] = widget.phoneNumber;
                        request.fields['otp'] = value;
                        if(widget.user_id!=null){
                          request.fields['fcm_token'] =
                            Provider.of<UserData>(context, listen: false)
                                .fcmKey;
                        request.fields['device_id'] =
                            Provider.of<UserData>(context, listen: false)
                                .deviceID;
                        }
                        print(request.fields);
                        commonMethod(request).then((onResponse) {
                          onResponse.stream
                              .transform(utf8.decoder)
                              .listen((value) {
                                print(value);
                            Map data = json.decode(value);
                            print(data);
                            if (data["code"] == 200) {
                              if(widget.user_id!=null){
                                Provider.of<UserData>(context, listen: false)
                                  .storeLoginData(
                                      data['user'], data['cart_count']);
                              Navigator.pushAndRemoveUntil(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => Home()),
                                (Route<dynamic> route) => false,
                              );
                              }else{
                                 Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => ForgetPasswordScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            } else {
                              presentToast(data['message'], context, 2);
                              getProgressDialog(context, "Verifying")
                                  .hide(context);
                            }
                          });
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Didn't you received any code?",
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    getProgressDialog(context, "Please wait...").show();
                    var request = MultipartRequest(
                        "POST", Uri.parse(api_url + "verify_mobile"));
                    request.fields['user_id'] = widget.user_id.toString();
                    request.fields['phone'] = widget.phoneNumber;
                    commonMethod(request).then((onResponse) {
                      onResponse.stream.transform(utf8.decoder).listen((value) {
                        Map data = json.decode(value);
                        print(data);
                        if (data["code"] == 200) {
                          getProgressDialog(context, "Verifying").hide(context);
                        } else {
                          getProgressDialog(context, "Verifying").hide(context);
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "Resend new code",
                      style: TextStyle(
                        fontSize: 19,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
