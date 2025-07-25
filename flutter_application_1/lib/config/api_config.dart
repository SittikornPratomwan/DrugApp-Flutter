class ApiConfig {
  static const String baseURL = 'http://192.168.56.111:8516';
  
  // Authentication endpoints
  static const String loginEndpoint = '$baseURL/drugs/auth/login';
  static const String logoutEndpoint = '$baseURL/drugs/auth/logout';
  
  // Drug endpoints
  static const String drugsProductEndpoint = '$baseURL/drugs/product/';
  static const String remindersEndpoint = '$baseURL/drugs/product/reminders?userId';
  static const String addDrugReceiveEndpoint = '$baseURL/drugs/product/adddrugreceive';
  static const String dispenseDrugEndpoint = '$baseURL/drugs/dispense';
  static const String drugsProductItemEndpoint = '$baseURL/drugs/product/item';
  static const String dropdownStatusEndpoint = '$baseURL/drugs/product/dropdownstatus';
  
  // Other endpoints can be added here
  // static const String userEndpoint = '$baseURL/users';
  // static const String orderEndpoint = '$baseURL/orders';
}
