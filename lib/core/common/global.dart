import 'package:connecteo/connecteo.dart';
import 'package:get/get.dart';
import 'common_ui.dart';
import '../language/string_constants.dart';

/// Provides global utility functions used across the application.
class Global {
  static final connecteo = ConnectionChecker();
  static var isInternetConnect = false.obs;
  static bool isSessionExpired=false;

  /// Checks internet connectivity, updates state, and optionally shows an error message.
  static Future<bool> checkInternet({bool showMsg = true}) async {
    final status = await connecteo.isConnected;

    if (status) {
      isInternetConnect.value = true;
      return true;
    } else {
      isInternetConnect.value = false;

      if (showMsg) {
        CommonUI.showApiSnackBar(
          isSuccess: false,
          message: StringConstants.kCheckInternetConnection.tr,
        );
      }
      return false;
    }
  }
}
