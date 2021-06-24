import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/screens/login.dart';
import 'package:littardo/screens/verifynumber.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/progressdialog.dart';
import 'package:littardo/widgets/edittext.dart';
import 'package:littardo/widgets/submitbutton.dart';

class RegisterScreen extends StatefulWidget {
  _RegisterScreen createState()=> _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  ProgressDialog progressDialog;
  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _emailcontroller = new TextEditingController();
  TextEditingController _passcontroller = new TextEditingController();
  TextEditingController _referalcontroller = new TextEditingController();
  TextEditingController _confirmcontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    "Register account",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ),
                EditText(title: "Name",textEditingController: _namecontroller,),
                EditText(title: "Email",textEditingController: _emailcontroller,),
                EditText(title: "Password",textEditingController: _passcontroller,),
                EditText(title: "Confirm Password",textEditingController: _confirmcontroller,),
                EditText(title: "Referral Code (If any)",textEditingController: _referalcontroller,),
                SubmitButton(
                  title: "Register",
                  act: () {
                    if (_namecontroller.text.length==0) {
                      presentToast('Please enter your name', context, 2);
                    }else if (!validateEmail(_emailcontroller.text)) {
                      presentToast('Please enter valid email', context, 2);
                    } else if (_passcontroller.text.length == 0) {
                      presentToast('Please enter password', context, 2);
                    } else if (_confirmcontroller.text.length == 0) {
                      presentToast('Please confirm password', context, 2);
                    } else if (_passcontroller.text != _confirmcontroller.text) {
                      presentToast('Password mismatch! Please check', context, 2);
                    } else {
                      getProgressDialog(context, 'Verifying...').show();
                      var request = new MultipartRequest(
                          "POST", Uri.parse(api_url + "register"));
                      request.fields['name'] = _namecontroller.text;
                      request.fields['email'] = _emailcontroller.text;
                      request.fields['password'] = _passcontroller.text;
                      request.fields['referral_code'] = _referalcontroller.text;
                      commonMethod(request).then((onResponse) {
                        onResponse.stream
                            .transform(utf8.decoder)
                            .listen((value) {
                          Map data = json.decode(value);
                          print(data);
                          presentToast(data['message'], context, 2);
                          if (data['code'] == 200) {
//                            storeLoginData(data['user'], data['cart_count']);
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
                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Already exist account? ",
                        style: TextStyle(fontSize: 17),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 17),
                        ),
                      ),
                    ],
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
