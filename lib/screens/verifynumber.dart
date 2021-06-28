import 'dart:convert';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:littardo/screens/verificationcode.dart';
import 'package:littardo/services/api_services.dart';
import 'package:littardo/utils/countrydropdown.dart';
import 'package:littardo/utils/progressdialog.dart';
import 'package:littardo/widgets/socialbottomsheet.dart';
import 'package:littardo/widgets/submitbutton.dart';

class VerifyScreeen extends StatefulWidget {
  final Map user;
  VerifyScreeen({this.user});
  @override
  _VerifyScreeenState createState() => _VerifyScreeenState();
}

class _VerifyScreeenState extends State<VerifyScreeen> {
  var _txtNumber = TextEditingController();
  String _txtNumberHint = "";

  @override
  void initState() {
    _txtNumber.addListener(() {
      setState(() {
        _txtNumberHint = _txtNumber.text;
        print("Text Number Value: ${_txtNumber.text}");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 96.0),
            child: Column(
              children: <Widget>[   Image.asset(
          "assets/littardo_logo.jpg",
          height: 90,
          width: 90,
        ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("Verify your phone number",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.title),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, bottom: 36.0),
                  child: Text(
                      _txtNumberHint.isEmpty
                          ? "Please enter mobile number to get OTP."
                          : "We will send you an SMS with a code to number +91 $_txtNumberHint",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle),
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, bottom: 8.0, left: 24.0, right: 24.0),
                      child: TextField(
                        enabled: false,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          fillColor: Theme.of(context).dividerColor,
                          hintStyle: Theme.of(context).textTheme.subtitle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 36.0, bottom: 8.0, left: 36.0, right: 24.0),
                      child: IgnorePointer(
                        ignoring: true,
                        child: CountryPickerDropdown(
                          initialValue: 'in',
                          itemBuilder: _buildDropdownItem,
                          onValuePicked: (Country country) {
                            print("${country.name}");
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, bottom: 8.0, left: 184.0, right: 24.0),
                      child: TextField(
                        controller: _txtNumber,
                        maxLength: 10,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.timesCircle,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _txtNumber.text = "";
                              });
                              print("clear textnumber icon pressed.");
                            },
                          ),
                          hintText: "I  Number",
                          hintStyle: Theme.of(context).textTheme.display2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
                widget.user!=null?Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Or login with   ",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      GestureDetector(
                        onTap: () {
                          socialBottomSheet(context);
                          print("Social Network pressed");
                        },
                        child: Text(
                          "Social Network",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ):SizedBox(),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: SubmitButton(
                  title: "Next",
                  act: () async {
                              if (_txtNumber.text.length == 10) {
                                getProgressDialog(context, "Verifying").show();
                                var request = MultipartRequest("POST",
                                    Uri.parse(widget.user!=null?api_url + "verify_mobile":api_url + "reset/password"));
                               if(widget.user!=null){
                                  request.fields['user_id'] =
                                    widget.user["id"].toString();
                               }
                                request.fields['phone'] =_txtNumber.text;
                                commonMethod(request).then((onResponse) {
                                  onResponse.stream
                                      .transform(utf8.decoder)
                                      .listen((value) {
                                    Map data = json.decode(value);
                                    print(data);
                                    if (data["code"] == 200) {
                                      getProgressDialog(context, "Verifying")
                                          .hide(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerificationScreen(
                                            phoneNumber: _txtNumber.text,
                                                user_id:widget.user!=null?widget.user["id"].toString():null,
                                          ),
                                        ),
                                      );
                                    } else {
                                      presentToast(data["message"], context, 2);
                                      getProgressDialog(context, "Verifying")
                                          .hide(context);
                                    }
                                  });
                                });
                              }
                            },
                            // child: new Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     vertical: 15.0,
                            //     horizontal: 10.0,
                            //   ),
                            //   child: new Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: <Widget>[
                            //       new Expanded(
                            //         child: Text(
                            //           "Next",
                            //           textAlign: TextAlign.center,
                            //           style: TextStyle(
                            //               color: Colors.white,
                            //               fontWeight: FontWeight.bold),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ),
                        ),
                      ],
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

Widget _buildDropdownItem(Country country) => Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 8.0,
        ),
        Text(
          "+${country.phoneCode}(${country.isoCode})",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );

void socialBottomSheet(context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SocialBottomSheet();
      });
}
