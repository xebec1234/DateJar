class ApiConstants {
  static const String baseUrl = "https://datejar-backend.onrender.com/api";
  // static const String baseUrl = "http://127.0.0.1:8000/api";
  // static const String baseUrl = "http://172.21.48.1:8000/api";

  //auth api's
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String logout = "$baseUrl/logout";
  static const String googleLogin = "$baseUrl/google-login";

  //user info api's
  static const String users = "$baseUrl/user";

  //partners api's
  static const String partners = "$baseUrl/partners/search";
  static const String addPartner = "$baseUrl/partners";
  static String removePartner(String partnerRecordId) =>
      "$baseUrl/partners/$partnerRecordId";

  // Goals APIs
  static const String goals = "$baseUrl/goals";
  static const String activeGoals = "$baseUrl/goals/active";
  static String removeGoal(String goalId) => "$baseUrl/goals/$goalId";

  // Savings APIs
  static const String savings = "$baseUrl/savings";
  static String showSaving(String savingId) => "$baseUrl/savings/$savingId";
  static String updateSaving(String savingId) => "$baseUrl/savings/$savingId";
  static String removeSaving(String savingId) => "$baseUrl/savings/$savingId";
  static const String activeSavings = "$baseUrl/savings/active";
}
