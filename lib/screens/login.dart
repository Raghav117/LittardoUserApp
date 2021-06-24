import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/screens/register.dart';
import 'package:littardo/screens/verifynumber.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/progressdialog.dart';
import 'package:littardo/widgets/edittext.dart';
import 'package:littardo/widgets/submitbutton.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ProgressDialog progressDialog;
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context, ProgressDialogType.Normal);
    progressDialog.setMessage('Logging in...');
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Image.asset(
          "assets/littardo_logo.jpg",
          height: 90,
          width: 90,
        ),
        SizedBox(height: 20,),
                Text("Welcome", style: Theme.of(context).textTheme.title),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("Login to your account",
                      style: Theme.of(context).textTheme.subtitle),
                ),
                EditText(
                  title: "Email",
                  textEditingController: _emailcontroller,
                ),
                EditText(
                  title: "Password",
                  textEditingController: _passcontroller,
                ),
                SubmitButton(
                  title: "Login",
                  act: () async {
                    if (!validateEmail(_emailcontroller.text)) {
                      presentToast('Please enter valid email', context, 2);
                    } else if (_passcontroller.text.length == 0) {
                      presentToast('Please enter password', context, 2);
                    } else {
                      getProgressDialog(context, 'Logging in...').show();
                      var request = new MultipartRequest(
                          "POST", Uri.parse(api_url + "login"));
                      request.fields['email'] = _emailcontroller.text;
                      request.fields['password'] = _passcontroller.text;
                      request.fields['fcm_token'] =
                          Provider.of<UserData>(context, listen: false).fcmKey;
                      request.fields['device_id'] =
                          Provider.of<UserData>(context, listen: false)
                              .deviceID;
                      print(request.fields);
                      commonMethod(request).then((onResponse) {
                        onResponse.stream
                            .transform(utf8.decoder)
                            .listen((value) {
                          Map data = json.decode(value);
                          print(data);
                          presentToast(data['message'], context, 0);
                          if (data['code'] == 200) {
                            Provider.of<UserData>(context, listen: false)
                                .storeLoginData(
                                    data['user'], data['cart_count']);
                            Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => Home()),
                              (Route<dynamic> route) => false,
                            );
                          } else if (data['code'] == 403) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerifyScreeen(
                                  user: data['user'],
                                ),
                              ),
                            );
                          } else {
                            getProgressDialog(context, "Verifying")
                                .hide(context);
                          }
                        });
                      });
                    }
                  },
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerifyScreeen(
                                ),
                              ),
                            );
                  },
                                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text("Forgot your password?"),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don't have an account?  ",
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
