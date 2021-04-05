class VerifyModelUPI {
  int statusCode;
  String statusMessage;
  Data data;

  VerifyModelUPI({this.statusCode, this.statusMessage, this.data});

  VerifyModelUPI.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['statusMessage'] = this.statusMessage;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  String mid;
  String moid;
  String phone;
  String orderType;
  String gokwikOid;
  String total;
  bool merchantUserVerified;
  Msg msg;
  String requestId;
  String authToken;
  String paymentMethod;
  String paymentLink;
  String timer;
  bool cancelButton;
  List<String> uapp;
  String uLink;
  String transactionId;
  String qrCode;

  Data(
      {this.mid,
      this.moid,
      this.phone,
      this.orderType,
      this.gokwikOid,
      this.total,
      this.merchantUserVerified,
      this.msg,
      this.requestId,
      this.authToken,
      this.paymentMethod,
      this.paymentLink,
      this.timer,
      this.cancelButton,
      this.uapp,
      this.uLink,
      this.transactionId,
      this.qrCode});

  Data.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    moid = json['moid'];
    phone = json['phone'];
    orderType = json['order_type'];
    gokwikOid = json['gokwik_oid'];
    total = json['total'];
    merchantUserVerified = json['merchant_user_verified'];
    msg = json['msg'] != null ? new Msg.fromJson(json['msg']) : null;
    requestId = json['request_id'];
    authToken = json['auth_token'];
    paymentMethod = json['payment_method'];
    paymentLink = json['payment_link'];
    timer = json['timer'];
    cancelButton = json['cancelButton'];
    uapp = json['uapp']?.cast<String>() ?? null;
    uLink = json['u_link'];
    transactionId = json['transaction_id'];
    qrCode = json['qrCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mid'] = this.mid;
    data['moid'] = this.moid;
    data['phone'] = this.phone;
    data['order_type'] = this.orderType;
    data['gokwik_oid'] = this.gokwikOid;
    data['total'] = this.total;
    data['merchant_user_verified'] = this.merchantUserVerified;
    if (this.msg != null) {
      data['msg'] = this.msg.toJson();
    }
    data['request_id'] = this.requestId;
    data['auth_token'] = this.authToken;
    data['payment_method'] = this.paymentMethod;
    data['payment_link'] = this.paymentLink;
    data['timer'] = this.timer;
    data['cancelButton'] = this.cancelButton;
    data['uapp'] = this.uapp;
    data['u_link'] = this.uLink;
    data['transaction_id'] = this.transactionId;
    data['qrCode'] = this.qrCode;
    return data;
  }
}

class Msg {
  String heading;
  String subheading;

  Msg({this.heading, this.subheading});

  Msg.fromJson(Map<String, dynamic> json) {
    heading = json['heading'];
    subheading = json['subheading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['heading'] = this.heading;
    data['subheading'] = this.subheading;
    return data;
  }
}
