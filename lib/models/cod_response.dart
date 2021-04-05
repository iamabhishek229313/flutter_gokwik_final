import 'package:flutter_gokwik/models/payment_capture_model.dart';

class CODResponse {
  final PaymentResponse paymentResponse;
  final bool merchantUserVerified;

  CODResponse(this.paymentResponse, this.merchantUserVerified);
}
