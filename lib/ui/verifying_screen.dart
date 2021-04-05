import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gokwik/flutter_gokwik.dart';
import 'package:flutter_gokwik/models/cod_response.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik/models/verify/verify_model_cod.dart';
import 'package:flutter_gokwik/models/verify/verify_model_upi.dart';
import 'package:flutter_gokwik/services/apis.dart';
import 'package:flutter_gokwik/ui/otp_screen.dart';
import 'package:flutter_gokwik/ui/upi_pay_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class VerifyingScreen extends StatefulWidget {
  final bool isUPI;
  final GokwikData data;
  final bool isProduction;

  const VerifyingScreen({Key key, this.isUPI, this.data, this.isProduction}) : super(key: key);
  @override
  _VerifyingScreenState createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<VerifyingScreen> {
  var verifyModel;

  // We first do the verification with the given data.
  Future<dynamic> _getVerified() async {
    log("get Verified");
    var url = widget.isProduction ? ProductionAPI.verify : TestAPI.verify;
    var response;

    /// [Merchant response]
    try {
      response = await http.post(url, body: {
        "request_id": widget.data.requestId,
        "gokwik_oid": widget.data.gokwikOid,
        "order_status": widget.data.orderStatus,
        "total": widget.data.total,
        "moid": widget.data.moid,
        "mid": widget.data.mid,
        "phone": widget.data.phone,
        "order_type": widget.data.orderType,
        "os_type": Platform.isAndroid ? "android" : "ios"
      });
    } catch (e) {
      log(e.toString());
    }

    log("Verify reponse = " + response.body.toString());

    if (widget.isUPI) {
      verifyModel = VerifyModelUPI.fromJson(json.decode(response.body));
    } else {
      verifyModel = VerifyModelCOD.fromJson(json.decode(response.body));
    }

    /// [Analytics - 1]
    var analyticsResponse = await http.get((widget.isProduction)
        ? ProductionAnalyticsAPI.analytics1
        : TestAnalyticsAPI.analytics1 + (widget.isUPI ? "upi" : "cod") + "&request_id=" + widget.data.requestId);

    PaymentResponse paymentResponse;
    if (widget.isUPI) {
      paymentResponse = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => UPIPayScreen(
                verifyModel: verifyModel,
                isProduction: widget.isProduction,
              )));
      Navigator.pop(context, paymentResponse);
    } else {
      paymentResponse = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OTPScreen(
                verifyModelCOD: verifyModel,
                isProduction: widget.isProduction,
              )));
      Navigator.pop(context, CODResponse(paymentResponse, verifyModel.data.merchantUserVerified));
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getVerified(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData)
          return Scaffold(
            body: Center(
              child: Container(
                height: double.maxFinite,
                child: Column(
                  children: [
                    Spacer(),
                    SpinKitRing(
                      color: Colors.green,
                      lineWidth: 4.0,
                      size: 38.0,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Verifying order ...",
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    BottomLogo(screenHeight: MediaQuery.of(context).size.height * 0.8)
                  ],
                ),
              ),
            ),
          );
        return SizedBox();
      },
    );
  }
}
