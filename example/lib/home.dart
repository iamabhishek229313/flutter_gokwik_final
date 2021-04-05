import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gokwik/flutter_gokwik.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Gokwik _gokwik;
  String phoneNumber;

  TextEditingController _phoneNumberController;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _gokwik = Gokwik();
    _phoneNumberController = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void createOrder(bool isUPI) async {
    var rng = new math.Random();
    String orderId = (rng.nextInt(900000) + 100000).toString();

    log(orderId);

    Map<String, dynamic> _data = {
      "order": {
        "id": orderId,
        "status": "pending",
        "total": "1.00",
        "subtotal": "1",
        "total_line_items": "1",
        "total_line_items_quantity": "3",
        "total_tax": "0",
        "total_shipping": "0.00",
        "total_discount": "0",
        "payment_details": {"method_id": isUPI ? "upi" : "cod"},
        "billing_address": {
          "first_name": "Test",
          "last_name": "Shop",
          "company": "Test",
          "address_1": "Test",
          "address_2": "",
          "city": "Delhi",
          "state": "DL",
          "postcode": "110092",
          "country": "IN",
          "email": "v@gokwik.co",
          "phone": phoneNumber
        },
        "shipping_address": {
          "first_name": "",
          "last_name": "",
          "company": "",
          "address_1": "",
          "address_2": "",
          "city": "",
          "state": "",
          "postcode": "",
          "country": ""
        },
        "customer_ip": "103.82.80.57",
        "customer_user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:86.0) Gecko/20100101 Firefox/86.0",
        "line_items": [
          {
            "product_id": 15,
            "variant_id": "12",
            "product": {},
            "name": "Beanie",
            "sku": "woo-beanie",
            "price": 18,
            "quantity": 3,
            "subtotal": "18",
            "total": "54",
            "tax": "0",
            "taxclass": "",
            "taxstat": "taxable",
            "allmeta": [],
            "somemeta": "",
            "type": "line_item",
            "product_url": "https://woo.akash.guru/product/beanie/",
            "product_thumbnail_url": "https://woo.akash.guru/wp-content/uploads/2021/01/beanie-2-150x150.jpg"
          }
        ],
        "source": "aaa",
        "promo_code": "aaa",
        "order_notes": "[]"
      }
    };

    Map<String, String> headers = {
      "appid": "d32528805bc1bf7d26900007e9eb7f22",
      "appsecret": "435c485ef6adb9c1468a633f487dc509",
      "Content-Type": "application/json"
    };

    var response =
        await http.post('https://sandbox.gokwik.co/v1/order/create', headers: headers, body: json.encode(_data));

    var decodedResponse = json.decode(response.body);
    log("API RESPONSE/create" + response.body.toString());

    /// [Some Dummy Details]
    String request_id = decodedResponse["data"]["request_id"];
    String gokwik_oid = decodedResponse["data"]["gokwik_oid"];
    String order_status = decodedResponse["data"]["order_status"];
    String total = decodedResponse["data"]["total"];
    String moid = decodedResponse["data"]["moid"];
    String mid = decodedResponse["data"]["mid"];
    String phone = decodedResponse["data"]["phone"];
    String order_type = decodedResponse["data"]["order_type"];

    /// [Start the Payment]
    _gokwik.initPayment(context,
        production: false, data: GokwikData(request_id, gokwik_oid, order_status, total, moid, mid, phone, order_type));

    void _handleSuccess(PaymentResponse paymentResponse) {
      log("main.dart == CALLBACK SUCCESS");
      if (mounted)
        _scaffoldKey?.currentState?.showSnackBar(
            SnackBar(backgroundColor: Colors.black, content: new Text(paymentResponse.toJson().toString())));
    }

    void _handleError(String response) {
      log("main.dart == CALLBACK ERROR");
      if (mounted)
        _scaffoldKey?.currentState?.showSnackBar(SnackBar(backgroundColor: Colors.red, content: new Text(response)));
    }

    _gokwik.on(Gokwik.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _gokwik.on(Gokwik.EVENT_PAYMENT_ERROR, _handleError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 10.0,
        title: const Text('GoKwik Flutter SDK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                phoneNumber = val;
              },
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  labelText: "Phone number",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  border: OutlineInputBorder(borderSide: new BorderSide(color: Colors.indigo))),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.maxFinite,
              child: RaisedButton(
                color: Colors.indigoAccent,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  createOrder(true);
                },
                child: Text(
                  "Pay through UPI",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.maxFinite,
              child: RaisedButton(
                color: Colors.indigoAccent,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  createOrder(false);
                },
                child: Text(
                  "Cash On Delivery",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
