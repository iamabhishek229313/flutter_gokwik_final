import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_gokwik/bloc/otp_bloc.dart';
import 'package:flutter_gokwik/const/app_colors.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik/models/verify/verify_model_cod.dart';
import 'package:flutter_gokwik/services/apis.dart';
import 'package:flutter_gokwik/ui/upi_pay_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:http/http.dart' as http;

class OTPScreen extends StatefulWidget {
  final VerifyModelCOD verifyModelCOD;
  final bool isProduction;

  const OTPScreen({Key key, this.verifyModelCOD, this.isProduction}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otpText = "";

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sendOTP(widget.verifyModelCOD, context);
      final data = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          elevation: 10.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
          builder: (BuildContext context) {
            return WillPopScope(onWillPop: () {}, child: _getWidget());
          });

      Navigator.pop(context, data);
    });
  }

  Future<bool> _fakeLoad() async {
    Future.delayed(Duration(milliseconds: 90), () {
      return Future.value(true);
    });
    return Future.value(false);
  }

  Widget _getWidget() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    CountdownTimerController _countdownTimerController = CountdownTimerController(endTime: 30, onEnd: () {});

    Widget otp = MultiBlocProvider(
        providers: [
          BlocProvider<OTPCorrectBloc>(
            create: (BuildContext context) => OTPCorrectBloc(),
          ),
          BlocProvider<SubmitAvailableBloc>(
            create: (BuildContext context) => SubmitAvailableBloc(),
          ),
        ],
        child: AnimatedContainer(
            duration: Duration(milliseconds: 110),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
              color: Colors.grey.shade100,
            ),
            height: screenHeight * 0.75,
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 16.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                      child: FutureBuilder(
                        future: _fakeLoad(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData)
                            return Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SpinKitRing(
                                        color: Colors.green,
                                        lineWidth: 4.0,
                                        size: 32.0,
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        "Sending OTP ...",
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                ),
                                BottomLogo(screenHeight: MediaQuery.of(context).size.height * 0.8)
                              ],
                            );
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Order Successfully Placed",
                                style: TextStyle(
                                    color: Colors.green.shade600, fontSize: 22.0, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Text(
                                "Order Id " + widget.verifyModelCOD.data.gokwikOid,
                                style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              Container(
                                width: double.maxFinite,
                                height: screenHeight * 0.085,
                                margin: const EdgeInsets.symmetric(vertical: 16.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration:
                                    BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6.0)),
                                child: Row(
                                  children: [
                                    Image.network(
                                      "https://s3.ap-south-1.amazonaws.com/cdn.sandbox.gokwik.co/images/sms-alert.png",
                                      height: screenHeight * 0.05,
                                      width: screenHeight * 0.05,
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Get FREE delivery updates on WhatsApp or SMS",
                                            maxLines: 3,
                                            style: TextStyle(
                                                color: Colors.red.shade500,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            "Verify your number now",
                                            maxLines: 3,
                                            style: TextStyle(
                                                color: Colors.red.shade500,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenHeight * 0.02),
                              Text(
                                "Enter the OTP you received on\n${widget.verifyModelCOD.data.phone}",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0, wordSpacing: 1.2, fontWeight: FontWeight.w500),
                              ),
                              OTPTextField(
                                length: 6,
                                width: double.maxFinite,
                                textFieldAlignment: MainAxisAlignment.spaceEvenly,
                                fieldWidth: MediaQuery.of(context).size.width / 12,
                                onChanged: (val) {
                                  if (mounted) if (val.length < 6)
                                    BlocProvider.of<SubmitAvailableBloc>(context).add(SubmitAvailableEvent.FALSE);
                                  otpText = val;
                                },
                                fieldStyle: FieldStyle.underline,
                                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.black),
                                onCompleted: (pin) {
                                  BlocProvider.of<SubmitAvailableBloc>(context).add(SubmitAvailableEvent.TRUE);
                                },
                              ),
                              BlocBuilder<OTPCorrectBloc, bool>(
                                builder: (context, isCorrect) {
                                  return (isCorrect)
                                      ? SizedBox(height: screenHeight * 0.03)
                                      : Padding(
                                          padding: EdgeInsets.only(top: screenHeight * 0.02),
                                          child: Text(
                                            "OTP doesn't match",
                                            style: TextStyle(
                                                color: Colors.red.shade600,
                                                letterSpacing: 1.1,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0).copyWith(top: screenHeight * 0.03),
                                child: SizedBox(
                                  height: screenHeight * 0.06,
                                  width: MediaQuery.of(context).size.width / 1.5,
                                  child: BlocBuilder<SubmitAvailableBloc, bool>(
                                    builder: (context, enabled) {
                                      return RaisedButton(
                                        onPressed: enabled
                                            ? () async {
                                                bool verifyData = await _verifyOTP(otpText);
                                                BlocProvider.of<OTPCorrectBloc>(context)
                                                    .add((verifyData ? OTPCorrectEvent.TRUE : OTPCorrectEvent.FALSE));
                                              }
                                            : null,
                                        color: Colors.green.shade500,
                                        child: Text(
                                          "SUBMIT",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenHeight * 0.01),
                                child: ArgonTimerButton(
                                  height: screenHeight * 0.03,
                                  initialTimer: 30,
                                  elevation: 0.0,
                                  roundLoadingShape: false,
                                  minWidth: MediaQuery.of(context).size.width / 2,
                                  width: MediaQuery.of(context).size.width / 2,
                                  color: Colors.white,
                                  borderRadius: 2.0,
                                  disabledColor: Colors.greenAccent,
                                  disabledElevation: 0.0,
                                  child: Text(
                                    "Resend OTP",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline),
                                  ),
                                  loader: (timeLeft) {
                                    return RichText(
                                      maxLines: 1,
                                      text: TextSpan(
                                        text: 'Resend OTP in ',
                                        style: TextStyle(
                                            fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.normal),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '00:$timeLeft',
                                              style: TextStyle(
                                                  fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    );
                                  },
                                  onTap: (startTimer, btnState) {
                                    if (btnState == ButtonState.Idle) {
                                      _resendOTP();
                                      startTimer(30);
                                    } else if (btnState == ButtonState.Busy) {}
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  BottomLogo(screenHeight: screenHeight)
                ],
              ),
            )));

    return otp;
  }

  /// Used for [Cash On Delivery] Payment Option
  Future<http.Response> _sendOTP(var verifyModel, BuildContext context) async {
    var response = await http.post(widget.isProduction ? ProductionAPI.sendOTP : TestAPI.sendOTP, body: {
      "mid": widget.verifyModelCOD.data.mid,
      "phone": widget.verifyModelCOD.data.phone,
      "order_type": widget.verifyModelCOD.data.orderType,
      "moid": widget.verifyModelCOD.data.moid
    });
    return response;
  }

  Future<bool> _verifyOTP(String otpEntered) async {
    var response = await http.post(widget.isProduction ? ProductionAPI.verifyOTP : TestAPI.verifyOTP,
        body: {"otp": otpEntered, "phone": widget.verifyModelCOD.data.phone});

    var decodedRepsonse = json.decode(response.body);

    final PaymentResponse paymentResponse = PaymentResponse.fromJson(decodedRepsonse);

    if (decodedRepsonse['statusCode'] == 200) {
      Navigator.pop(context, paymentResponse);
    } else {
      return false;
    }

    return true;
  }

  Future<http.Response> _resendOTP() async {
    var response = await http.post(widget.isProduction ? ProductionAPI.resendOTP : TestAPI.resendOTP, body: {
      "mid": widget.verifyModelCOD.data.mid,
      "phone": widget.verifyModelCOD.data.phone,
      "order_type": widget.verifyModelCOD.data.orderType,
      "moid": widget.verifyModelCOD.data.moid
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.0,
        leading: null,
      ),
      body: SingleChildScrollView(
        child: Container(
            height: screenHeight - AppBar().preferredSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    height: screenHeight * 0.06,
                    width: double.maxFinite,
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                                text: '₹' + widget.verifyModelCOD.data.total,
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );
  }
}
