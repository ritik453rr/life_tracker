/// Handles local storage operations for authentication, tokens, and user session management.
class AppStorage {

  /// Returns auth token
  static String getAuthToken() {
    // TODO: Replace with actual storage logic
    return "";
  }

  /// Returns FCM token
  static String getFcmToken() {
    // TODO: Replace with actual storage logic
    return "";
  }

  /// Checks if user is logged in
  static bool isLoggedIn() {
    return getAuthToken().isNotEmpty;
  }

  /// Clears user session / logout
  static void logOut() {
    // TODO: Clear storage, tokens, and navigate to login
  }
}
