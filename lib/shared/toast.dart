import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showToast({@required String message, @required BuildContext context}) {
  Flushbar(
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: EdgeInsets.all(8.0),
    duration: Duration(seconds: 4),
    borderRadius: 5.0,
    reverseAnimationCurve: Curves.linear,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    // mainButton: FlatButton(
    //   onPressed: () {
    //     Navigator.pop(context);
    //   },
    //   child: Text(
    //     'OK',
    //     style: TextStyle(color: Colors.amber, fontFamily: 'Product Sans'),
    //   ),
    // ),
    messageText: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Product Sans',
      ),
    ),
  )..show(context);
}
