class ApiConstants {
  static const String baseUrl =
      "https://plantsync-backend-a8c5cbd9c5bggfg3.mexicocentral-01.azurewebsites.net/api/v1";

  static const String signIn = "$baseUrl/authentication/sign-in";
  static const String signUp = "$baseUrl/authentication/sign-up";
  static const String users = "$baseUrl/users";
  static const String profiles = "$baseUrl/profiles";
  static const String account = "$baseUrl/account";
  static const String plants = "$baseUrl/plants";
  static const String tasks = "$baseUrl/tasks";
  static const String iotReadings = "$baseUrl/iot/readings";
  static const String iotNodes = "$baseUrl/iot/nodes";
  static const String iotEdge = "$baseUrl/iot/edge";
  static const String analyticsGlobalTelemetry = "$baseUrl/analytics/global-telemetry";
  static const String analyticsDeviceStatus = "$baseUrl/analytics/device-status";
  static const String weather = "$baseUrl/weather/city";
}
