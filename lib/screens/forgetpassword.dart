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

import 'login.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordScreen> {
  ProgressDialog progressDialog;
  TextEditingController _passcontroller = TextEditingController();
  TextEditingController _cnfpasscontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context, ProgressDialogType.Normal);
    progressDialog.setMessage('Reset progress...');
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Text("Welcome", style: Theme.of(context).textTheme.title),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("Reset your password",
                      style: Theme.of(context).textTheme.subtitle),
                ),
                EditText(
                  title: "New Password",
                  textEditingController: _passcontroller,
                ),
                EditText(
                  title: "Confirm Password",
                  textEditingController: _cnfpasscontroller,
                ),
                
                SubmitButton(
                  title: "Reset",
                  act: () async {
                    if (_passcontroller.text.length == 0) {
                      presentToast('Please enter password', context, 2);
                    } else if (_passcontroller.text!=_cnfpasscontroller.text) {
                      presentToast('Password mismatch', context, 2);
                    }else {
                      getProgressDialog(context, 'Reset progress...').show();
                      var request = new MultipartRequest(
                          "POST", Uri.parse(api_url + "change_password"));
                      request.fields['password'] = _passcontroller.text;
                      request.fields['fcm_token'] =
                          Provider.of<UserData>(context, listen: false).fcmKey;
                      print(request.fields);
                      request.headers['Authorization'] = "Bearer " +
                      Provider.of<UserData>(context, listen: false).userData['api_token'];
                      commonMethod(request).then((onResponse) {
                        onResponse.stream
                            .transform(utf8.decoder)
                            .listen((value) {
                          Map data = json.decode(value);
                          print(data);
                          presentToast(data['message'], context, 0);
                          if (data['code'] == 200) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                          }  else {
                            getProgressDialog(context, "Verifying")
                                .hide(context);
                          }
                        });
                      });
                    }
                  },
                ),
                // Padding(
                //   padding: const EdgeInsets.all(32.0),
                //   child: Text("Forgot your password?"),
                // ),
                // Row(
                //   mainAxisSize: MainAxisSize.max,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Text(
                //       "Don't have an account?  ",
                //       style: Theme.of(context).textTheme.subtitle,
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => RegisterScreen(),
                //           ),
                //         );
                //       },
                //       child: Text(
                //         "Sign Up",
                //         style: TextStyle(
                //             color: Theme.of(context).primaryColor,
                //             fontSize: 17),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
