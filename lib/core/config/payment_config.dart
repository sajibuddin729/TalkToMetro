/// SSLCommerz Payment Configuration
///
/// SANDBOX CREDENTIALS — কীভাবে এখানে credentials add করবেন:
/// 1. https://developer.sslcommerz.com/registration/ এ গিয়ে sandbox account খুলুন
/// 2. Email-এ Store ID এবং Store Password পাবেন
/// 3. নিচের দুটি constant-এ সেই credentials বসান
/// 4. Production এ যেতে হলে [isSandbox] = false করুন এবং live credentials দিন
///
/// NOTE: এই file-এ credentials রাখা dev/sandbox এর জন্য ঠিক আছে।
///       Production এ environment variables বা Flutter secure storage ব্যবহার করুন।

class PaymentConfig {
  // ══════════════════════════════════════════════════════════════════
  //  👇 আপনার SSLCommerz Sandbox Credentials এখানে বসান
  // ══════════════════════════════════════════════════════════════════
  static const String storeId = String.fromEnvironment(
    'SSL_STORE_ID',
    defaultValue: 'YOUR_SSLCOMMERZ_STORE_ID',
  );
  static const String storePassword = String.fromEnvironment(
    'SSL_STORE_PASSWORD',
    defaultValue: 'YOUR_SSLCOMMERZ_STORE_PASSWORD',
  );
  // ══════════════════════════════════════════════════════════════════

  /// Sandbox mode — testing এর জন্য true, production এ false করুন
  static const bool isSandbox = true;

  /// SSLCommerz supported payment methods
  /// bkash,nagad,visa,master,amex — comma separated
  static const String multiCardName = 'visa,master,bkash,nagad';

  /// Currency (BDT fixed for metro rail Bangladesh)
  static const String currency = 'BDT';

  /// Product category
  static const String productCategory = 'travel';
}
