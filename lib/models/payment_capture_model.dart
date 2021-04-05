class PaymentResponse {
  int statusCode;
  String statusMessage;
  Data data;

  PaymentResponse({this.statusCode, this.statusMessage, this.data});

  PaymentResponse.fromJson(Map<String, dynamic> json) {
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
  String paymentStatus;
  String orderStatus;
  String total;
  int orderId;
  String transactionId;
  String requestId;

  Data({this.paymentStatus, this.orderStatus, this.total, this.orderId, this.transactionId, this.requestId});

  Data.fromJson(Map<String, dynamic> json) {
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    total = json['total'];
    orderId = json['order_id'];
    transactionId = json['transaction_id'];
    requestId = json['request_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_status'] = this.paymentStatus;
    data['order_status'] = this.orderStatus;
    data['total'] = this.total;
    data['order_id'] = this.orderId;
    data['transaction_id'] = this.transactionId;
    data['request_id'] = this.requestId;
    return data;
  }
}
