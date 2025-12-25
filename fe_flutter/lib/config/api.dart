class Api {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static const String login = "$baseUrl/login";
  static const String products = "$baseUrl/products";
  // Default headers used by many services. Include Content-Type when sending JSON.
  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}
