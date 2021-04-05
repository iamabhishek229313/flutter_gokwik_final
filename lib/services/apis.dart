class TestAPI {
  static final String create = 'https://sandbox.gokwik.co/v1/order/create';
  static final String verify = 'https://sandbox.gokwik.co/v1/order/verify';
  static final String paymentCapture = 'https://sandbox.gokwik.co/v1/payment/capture';
  static final String sendOTP = 'https://sandbox.gokwik.co/v1/user/send-otp';
  static final String resendOTP = 'https://sandbox.gokwik.co/v1/user/resend-otp';
  static final String verifyOTP = 'https://sandbox.gokwik.co/v1/user/verify-otp';
}

class ProductionAPI {
  static final String create = 'https://api.gokwik.co/v1/order/create';
  static final String verify = 'https://api.gokwik.co/v1/order/verify';
  static final String paymentCapture = 'http://api.gokwik.co/v1/payment/capture';
  static final String sendOTP = 'https://api.gokwik.co/v1/user/send-otp';
  static final String resendOTP = 'https://api.gokwik.co/v1/user/resend-otp';
  static final String verifyOTP = 'https://api.gokwik.co/v1/user/verify-otp';
}

class TestAnalyticsAPI {
  static final String analytics1 = 'https://devhits.gokwik.co/api/analytics/events?event_type=page_load&event=';
  static final String analytics2 = 'https://devhits.gokwik.co/api/analytics/events?event_type=click&event=';
}

class ProductionAnalyticsAPI {
  static final String analytics1 = 'https://hits.gokwik.co/api/analytics/events?event_type=page_load&event=';
  static final String analytics2 = 'https://hits.gokwik.co/api/analytics/events?event_type=click&event=';
}
