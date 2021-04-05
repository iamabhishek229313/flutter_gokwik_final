import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gokwik/const/app_colors.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik/models/verify/verify_model_upi.dart';
import 'package:flutter_gokwik/services/apis.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:upi_pay/upi_pay.dart';

class UPIPayScreen extends StatefulWidget {
  final VerifyModelUPI verifyModel;
  final bool isProduction;

  const UPIPayScreen({Key key, @required this.verifyModel, this.isProduction}) : super(key: key);

  @override
  _UPIPayScreenState createState() => _UPIPayScreenState();
}

class _UPIPayScreenState extends State<UPIPayScreen> {
  Future<List<ApplicationMeta>> _appsFuture;
  Uint8List _bytesImage;
  Timer timer;
  bool waitingForResponse = false;

  @override
  void initState() {
    super.initState();
    _appsFuture = UpiPay.getInstalledUpiApplications();
    // log("Number of apps found in system : " + _appsFuture.length.toString());
    _bytesImage = Base64Decoder().convert(widget.verifyModel.data.qrCode.split('base64,')[1]);
    _initPaymentCapture();
  }

  /// Used for [UPI] Payment Option
  Future<http.Response> _paymentCapture() async {
    var response = await http.post(widget.isProduction ? ProductionAPI.paymentCapture : TestAPI.paymentCapture,
        body: {"gokwik_oid": widget.verifyModel.data.gokwikOid, "auth_token": widget.verifyModel.data.authToken});

    PaymentResponse paymentResponse = PaymentResponse.fromJson(json.decode(response.body.toString()));

    if (paymentResponse.data.paymentStatus == "PAID") {
      timer.cancel();
      Navigator.pop(context, paymentResponse);
      return response;
    } else if (paymentResponse.data.paymentStatus == "PENDING") {
    } else if (paymentResponse.data.paymentStatus == "ERROR") {
      timer.cancel();
      Navigator.pop(context, null);
      return response;
    }
    return response;
  }

  /// [Payment Capture]
  _initPaymentCapture() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!waitingForResponse) {
        waitingForResponse = true;
        await _paymentCapture();
        waitingForResponse = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _hitAnalytics(String upiAppName) async {
    var analyticsResponse = await http.get((widget.isProduction)
        ? ProductionAnalyticsAPI.analytics2
        : TestAnalyticsAPI.analytics2 + upiAppName + "&request_id=" + widget.verifyModel.data.requestId);

    return true;
  }

  Future<void> _onTap(ApplicationMeta app) async {
    await _hitAnalytics(app.upiApplication.getAppName());

    final transactionRef = math.Random.secure().nextInt(1 << 32).toString();

    String receiverUpiAddress = widget.verifyModel.data.uLink.split('pa=')[1].split('&')[0];

    final UpiTransactionResponse a = await UpiPay.initiateTransaction(
      amount: widget.verifyModel.data.total,
      app: app.upiApplication,
      receiverName: 'Gokwik',
      receiverUpiAddress: receiverUpiAddress,
      transactionRef: transactionRef,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // set up the buttons
        Widget yesButton = FlatButton(
          color: Colors.white,
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.green.shade800),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            timer.cancel();
            Navigator.of(context).pop(null);
          },
        );
        Widget noButton = FlatButton(
          color: Colors.white,
          child: Text(
            "No",
            style: TextStyle(color: Colors.green.shade800),
          ),
          onPressed: () => Navigator.of(context).pop(),
        );

        AlertDialog alert = AlertDialog(
          content: Text("Are you sure you want to cancel the payment?"),
          actions: [
            noButton,
            yesButton,
          ],
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Widget yesButton = FlatButton(
                color: Colors.white,
                child: Text(
                  "Yes",
                  style: TextStyle(color: Colors.green.shade800),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  timer.cancel();
                  Navigator.of(context).pop(null);
                },
              );
              Widget noButton = FlatButton(
                color: Colors.white,
                child: Text(
                  "No",
                  style: TextStyle(color: Colors.green.shade800),
                ),
                onPressed: () => Navigator.of(context).pop(),
              );

              AlertDialog alert = AlertDialog(
                content: Text("Are you sure you want to cancel the payment?"),
                actions: [
                  noButton,
                  yesButton,
                ],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          ),
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                      height: screenHeight * 0.06,
                      width: double.maxFinite,
                      padding: EdgeInsets.only(left: 16.0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            text: 'Pay ',
                            style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w300),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '₹' + widget.verifyModel.data.total,
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Select Any UPI Option",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: AppColors.white,
                  child: FutureBuilder<List<ApplicationMeta>>(
                    future: _appsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                          height: screenHeight * 0.4,
                          child: Center(
                              child: SpinKitRing(
                            color: Colors.green,
                            size: 24.0,
                            lineWidth: 2.0,
                          )),
                        );
                      else if (snapshot.data.length == 0)
                        return Container(
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0), color: Colors.yellow.shade300),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.yellow.shade800,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "No upi payment apps found. Don't worry use QR code to continue with",
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 14.0, color: Colors.deepOrange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: screenHeight * 0.08,
                                margin: EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0), color: Colors.grey.shade100),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 16.0,
                                      height: double.maxFinite,
                                      child: Stack(
                                        children: [
                                          Align(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(
                                                  8,
                                                  (index) => Container(
                                                        height: (screenHeight * 0.02) / 8,
                                                        width: 2.0,
                                                        color: Colors.indigo,
                                                      )),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                height: 8.0,
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo),
                                              )),
                                          Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                height: 8.0,
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo),
                                              ))
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Open any UPI App on other phone",
                                            maxLines: 2,
                                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                                          ),
                                          Text(
                                            "Scan QR Code to pay",
                                            maxLines: 2,
                                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 32.0,
                              ),
                              Image.memory(
                                _bytesImage,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                "Scan this QR Code",
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                              )
                            ],
                          )),
                        );

                      return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 24.0),
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            final it = snapshot.data[index];

                            if (!widget.verifyModel.data.uapp
                                .toString()
                                .toLowerCase()
                                .contains(it.upiApplication.getAppName().toLowerCase())) return SizedBox();

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              height: screenHeight * 0.08,
                              child: Material(
                                elevation: 5.0,
                                color: Colors.grey.shade50,
                                shadowColor: AppColors.shadow,
                                animationDuration: Duration(milliseconds: 200),
                                type: MaterialType.canvas,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                key: ObjectKey(it.upiApplication),
                                child: InkWell(
                                  onTap: () => _onTap(it),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.memory(
                                            it.icon,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 8.0).copyWith(left: 24.0),
                                          child: Text(
                                            (it.upiApplication.getAppName() == "tez")
                                                ? "GOOGLEPAY"
                                                : (it.upiApplication.getAppName() == "upi")
                                                    ? "BHIM"
                                                    : it.upiApplication.getAppName().toUpperCase(),
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.arrow_forward),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
              ),
              BottomLogo(screenHeight: screenHeight)
            ],
          ),
        ),
      ),
    );
  }
}

class BottomLogo extends StatelessWidget {
  const BottomLogo({
    Key key,
    @required this.screenHeight,
  }) : super(key: key);

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "POWERED BY ",
              style: TextStyle(fontSize: 8.0, color: Colors.grey),
            ),
            Image.network(
              "https://s3.ap-south-1.amazonaws.com/cdn.gokwik.co/logo/gokwik-cod-logo.gif",
              height: screenHeight * 0.02,
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
              child: Divider(
            height: 0.0,
            color: Colors.grey.shade300,
            endIndent: 16.0,
          )),
          Text(
            "Or",
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
          Expanded(
              child: Divider(
            height: 0.0,
            color: Colors.grey.shade300,
            indent: 16.0,
          )),
        ],
      ),
    );
  }
}
