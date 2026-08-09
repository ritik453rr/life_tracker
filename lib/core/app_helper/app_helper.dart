import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../common_widgets/app_snackbar.dart';
import '../language/string_constants.dart';

/// Provides helper utility functions used across the application.
class AppHelper {
  static final _connectivity = Connectivity();
  static var isInternetConnect = false.obs;
  static bool isSessionExpired = false;

  /// Checks internet connectivity, updates state, and optionally shows an error message.
  static Future<bool> checkInternet({bool showMsg = true}) async {
    final results = await _connectivity.checkConnectivity();
    final isConnected = results.any((result) => result != ConnectivityResult.none);

    if (isConnected) {
      isInternetConnect.value = true;
      return true;
    } else {
      isInternetConnect.value = false;

      if (showMsg) {
        AppSnackBar.showApiSnackBar(
          isSuccess: false,
          message: StringConstants.kCheckInternetConnection.tr,
        );
      }
      return false;
    }
  }
}
