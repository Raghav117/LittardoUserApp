import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:littardo/provider/UserData.dart';
import 'package:littardo/services/api_services.dart';
import 'package:provider/provider.dart';
class Transactions extends StatefulWidget{
 _Transactions createState()=> _Transactions();
}
class _Transactions extends State<Transactions>{
  bool serviceCalled = false;
  List transactions = [];
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) async {
     fetchProducts("wallet-transactions");
     });
    }
  @override
  Widget build(BuildContext context) {
  
    // TODO: implement build
    return Material(child: SafeArea(child: Stack(children: [Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top:40.0),
        child: ListView .builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: transactions.length,
                     itemBuilder: (context , index){
                       return  HistoryListTile(
                          iconColor: IconColors.transfer,
                          onTap: () {},
                          transactionAmount: "+\u20b9${transactions[index]['amount']}",
                          transactionIcon: transactions[index]['type']=="1"?IconImgs.transfer:IconImgs.send,
                          transactionName: transactions[index]['description'],
                          transactionType: transactions[index]['type']=="1"?"Credited":"Debited",
                        );
                     },
                    ),
      ),
              ),
              _backButton()],),),);
            
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

  fetchProducts(String method) {
    getProgressDialog(context, "Fetching Transactions...").show();
    commeonMethod2(api_url + method,
            Provider.of<UserData>(context, listen: false).userData['api_token'])
        .then((onResponse) {
      Map data = json.decode(onResponse.body);
      if (data['code'] == 200) {
        transactions.addAll(data['data']);
        setState(() {
          // pagesize += 1;
        });
        print(transactions.length);
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        serviceCalled = true;
      });
      getProgressDialog(context, "Fetching Transactions...").hide(context);
    });
  }
}

class HistoryListTile extends StatelessWidget {
  final Color iconColor;
  final String transactionName,
      transactionType,
      transactionAmount,
      transactionIcon;
  final GestureTapCallback onTap;
  const HistoryListTile({
    Key key,
    this.iconColor,
    this.transactionName,
    this.transactionType,
    this.transactionAmount,
    this.transactionIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(transactionName),
        subtitle: Text(transactionType,style: TextStyle(color: transactionType =="Credited"?Colors.green:Colors.red),),
        trailing: Text(transactionAmount,style: TextStyle(color: transactionType =="Credited"?Colors.green:Colors.red)),
        leading: CircleAvatar(
          radius: 25,
          child: Image.asset(
            transactionIcon,
            height: 25,
            width: 25,
          ),
          backgroundColor: iconColor,
        ),
        enabled: true,
        onTap: onTap,
      ),
    );
  }
}

class IconColors {
  static const Color send = Color(0xffecfaf8);
  static const Color transfer = Color(0xfffdeef5);
}

class IconImgs {
  static const String transfer = "assets/images/transfer.png";
  static const String send = "assets/images/send.png";
}