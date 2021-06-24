import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:littardo/utils/progressdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

String api_url = "https://littardoemporium.com/api/user/";

presentToast(msg, context, position) {
  Toast.show(msg, context,
      duration: Toast.LENGTH_LONG,
      backgroundColor: Color(0xff170e50),
      gravity: position);
}

Future<StreamedResponse> commonMethod(request) async {
  var response = await request.send();
  return response;
}

Future<Response> commeonMethod1(String token, String method) async {
  final response = await get(api_url + method, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    'Authorization': "Bearer $token",
    HttpHeaders.acceptHeader: 'application/json',
    "APP": 'ECOM',
  });

  return response;
}

Future<Response> commeonMethod2(String url, String token) async {
  print(url);
  final response = await get(
    url,
    headers: {
      'Authorization': "Bearer $token",
      "APP": "ECOM",
      "Accept": "application/json",
      // "Content-Type": "application/json"
    },
  );
  return response;
}

Future<Response> commeonMethod5(String url, String token) async {
  final response = await get(
    url,
    headers: {'Authorization': "Bearer $token", "APP": "ECOM"},
  );
  return response;
}

Future<Response> verifyMobile(String userId, String phone) async {
  Map body = {
    "user_id": userId,
    "phone": phone,
  };
  final response = await post(
    api_url + "user/verify",
    body: body,
  );

  print(response.body);
}

Future<Response> commeonMethod4(String url, String token) async {
  final response = await delete(
    url,
    headers: {
      'Authorization': "Bearer $token",
      "APP": "ECOM",
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
  );
  return response;
}

Future<Response> commeonMethod3(String url, Map data, String token,
    String extraParam, BuildContext context) async {
  Map<String, String> headers = {
    'Authorization': "Bearer $token",
    "APP": "ECOM",
    "Accept": "application/json",
    "Content-Type": "application/json"
  };
  print(headers);
  final response =
      await post(url, body: data, headers: headers).catchError((err) {
    print(err);
    presentToast(err.toString(), context, 0);
  });

  return response;
}

bool validateEmail(String email) {
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
  return emailValid;
}

ProgressDialog getProgressDialog(BuildContext context, String message) {
  ProgressDialog progressDialog =
      ProgressDialog(context, ProgressDialogType.Normal);
  progressDialog.setMessage(message);
  return progressDialog;
}
