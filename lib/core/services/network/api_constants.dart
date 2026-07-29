/// Contains API-related constant values and helper methods for error handling.
class ApiConstants {

  /// Returns a user-friendly error message based on the HTTP status code.
  static String getErrorMsg(int? statusCode) {
    switch (statusCode) {

      case 400:
        return "Bad request. Please check your input.";

      case 401:
        return "Unauthorized access. Please login again.";

      case 403:
        return "Forbidden request. You don’t have permission.";

      case 404:
        return "Requested resource not found.";

      case 408:
        return "Request timeout. Please try again.";

      case 409:
        return "Conflict occurred. Please refresh and try again.";

      case 422:
        return "Invalid data provided.";

      case 429:
        return "Too many requests. Please wait and try again.";

      case 500:
        return "Internal server error.";

      case 502:
        return "Bad gateway. Server is unavailable.";

      case 503:
        return "Service unavailable. Please try later.";

      case 504:
        return "Gateway timeout. Please try again.";

      default:
        return "Something went wrong.";
    }
  }
}
