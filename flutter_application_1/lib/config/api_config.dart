class ApiConfig {
  static const String baseURL = 'http://192.168.56.107:8516';
  
  // Authentication endpoints
  static const String loginEndpoint = '$baseURL/drugs/auth/login';
  static const String logoutEndpoint = '$baseURL/drugs/auth/logout';
  
  // Drug endpoints
  static const String drugsProductEndpoint = '$baseURL/drugs/product/';
  static const String remindersEndpoint = '$baseURL/drugs/product/reminders';
  
  // Other endpoints can be added here
  // static const String userEndpoint = '$baseURL/users';
  // static const String orderEndpoint = '$baseURL/orders';
}
