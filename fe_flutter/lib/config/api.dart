class Api {
  static const String baseUrl = "http://192.168.100.3:8000/api";

  static const String login = "$baseUrl/login";
  static const String products = "$baseUrl/products";

  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Helper endpoint (opsional tapi sangat direkomendasikan)
  static String receipt(String invoice) =>
      "$baseUrl/transactions/$invoice/receipt";
}
