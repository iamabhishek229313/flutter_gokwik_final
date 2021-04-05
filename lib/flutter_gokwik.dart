import 'dart:async';
import 'package:eventify/eventify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gokwik/models/cod_response.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik/ui/verifying_screen.dart';

class Gokwik {
  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'SUCCESS';
  static const EVENT_PAYMENT_ERROR = 'ERROR';

  // Method Channels
  static const MethodChannel _channel = const MethodChannel('flutter_gokwik');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  EventEmitter _eventEmitter;

  var verifyModel;
  Gokwik() {
    _eventEmitter = EventEmitter();
  }

  void initPayment(BuildContext context, {@required GokwikData data, @required bool production}) async {
    if (data.orderType == "upi") {
      final PaymentResponse _paymentResponse = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VerifyingScreen(
                isUPI: true,
                data: data,
                isProduction: production,
              )));

      if (_paymentResponse == null) {
        _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, "Canceled by user");
        _eventEmitter.clear();
        return;
      } else {
        if (_paymentResponse.statusCode == 200 && _paymentResponse.data.paymentStatus == 'PAID') {
          _eventEmitter.emit(Gokwik.EVENT_PAYMENT_SUCCESS, null, _paymentResponse);
          _eventEmitter.clear();
          return;
        } else {
          _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, _paymentResponse.statusMessage);
          _eventEmitter.clear();
          return;
        }
      }
    } else {
      final CODResponse _codResponse = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VerifyingScreen(
                isUPI: false,
                isProduction: production,
                data: data,
              )));
      if (_codResponse.merchantUserVerified == true) {
        if (_codResponse.paymentResponse == null) {
          _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, "Canceled by user");
          _eventEmitter.clear();
          return;
        } else {
          if (_codResponse.paymentResponse.statusCode == 200) {
            _eventEmitter.emit(Gokwik.EVENT_PAYMENT_SUCCESS, null, _codResponse.paymentResponse);
            _eventEmitter.clear();
            return;
          } else {
            _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, _codResponse.paymentResponse.statusMessage);
            _eventEmitter.clear();
            return;
          }
        }
      } else {
        _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_SUCCESS, null, PaymentResponse(statusCode: 200, statusMessage: "Mercent Verified"));
        _eventEmitter.clear();
        return;
      }
    }
  }

  /// Registers event listeners for payment events. [Handle Callbacks]
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
  }
}

class GokwikData {
  final String requestId;
  final String gokwikOid;
  final String orderStatus;
  final String total;
  final String moid;
  final String mid;
  final String phone;
  final String orderType;

  GokwikData(
      this.requestId, this.gokwikOid, this.orderStatus, this.total, this.moid, this.mid, this.phone, this.orderType);
}
