import 'dart:io';

void main() async {
  // --- STEP 1: Add dependencies first as requested ---
  await Struct.addDependencies();

  // --- STEP 2: Define and create directory tree ---
  final folders = [
    'lib/core/common',
    'lib/core/constants',
    'lib/core/storage',
    'lib/core/extension',
    'lib/core/services/network/model',
    'lib/core/language',
    'lib/core/routing',
    'lib/feature/splash',
    'assets/images/pngs',
    'assets/images/svgs',
    'assets/fonts',
  ];

  print('\n📂 Creating project directories...');
  for (var dir in folders) {
    Directory(dir).createSync(recursive: true);
  }

  // --- STEP 3: Define file payloads ---
  final filesWithContent = {
    /// -------------------- CONSTANTS --------------------
    'lib/core/constants/app_constants.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

/// Provides const utility across the application.
class AppConstants {

  /// Hide keyboard method
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Haptic feedback for the device
  static Future<void> hapticFeedBack() {
    if (GetPlatform.isIOS) {
      return HapticFeedback.lightImpact();
    } else {
      return HapticFeedback.vibrate();
    }
  }

  /// Set safe area color in view
  static void setSafeArea({bool isDark = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark ? AppColors.cBlack : AppColors.cWhite,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
''',

    /// Api response model
    'lib/core/services/network/model/response_model.dart': '''
/// Standard API response model used across network layer.
class ResponseModel {
  bool status;
  String message;
  dynamic data;

  ResponseModel({
    this.status = false,
    this.message = "",
    this.data = "",
  });
}
''',

    'lib/core/constants/app_keys.dart': '''
/// Stores environment keys used in the application.
class AppKeys {

  /// Production base URL key
  static const String prodBaseUrl = "PROD_BASE_URL";
}
''',

    'lib/core/services/network/api_urls.dart': '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../constants/app_keys.dart';

/// Contains all API endpoint URLs and base configuration.
class ApiUrl {

  /// BASE URL
  static String baseUrl =
      dotenv.env[AppKeys.prodBaseUrl] ?? "";
}
''',

    'lib/core/services/network/api_service.dart': '''

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../common/common_ui.dart';
import '../../common/global.dart';
import '../../language/string_constants.dart';
import '../../storage/app_storage.dart';
import 'api_constants.dart';
import 'api_urls.dart';
import 'model/response_model.dart';

/// A Singleton onboarding_service class that handles API requests using Dio.
class ApiService {
  // ---- Singleton Setup ----
  ApiService._internal() {
    _addAuthInterceptor();
  }

  static final ApiService _instance = ApiService._internal();

  // Public factory -> always same instance
  factory ApiService() => _instance;

  // ---- Single Dio Instance ----
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(minutes: 10),
      baseUrl: ApiUrl.baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  /// Adds authorization token to request headers if available in local storage.
  void _addAuthInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AppStorage.getAuthToken();
          final fcmToken = AppStorage.getFcmToken();
          options.headers['Authorization'] = 'Bearer \$token';
          options.headers['fcm-token'] = fcmToken;
          options.headers['platform'] = Platform.isAndroid ? "android" : "ios";
          handler.next(options);
        },
        onError: (options, handler) {
          if (options.response?.statusCode == 401 ||
              options.response?.statusCode == 502) {
            if (!Global.isSessionExpired) {
              Global.isSessionExpired = true;
              CommonUI.showApiSnackBar(
                message:
                    options.response?.data['message'] ??
                    StringConstants.kSomethingWentWrong.tr,
              );
              AppStorage.logOut();
            }

            return;
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Sends a POST request using Dio and returns a standardized ResponseModel with success, data, and error handling.
  Future<ResponseModel> postRequest({
    required String url,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    dynamic model,
    CancelToken? cancelToken,
  }) async {
    if (!await Global.checkInternet()) {
      return ResponseModel();
    }
    try {
      final response = await dio.post(
        url,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data["success"]) {
        return ResponseModel(
          status: true,
          data: model != null
              ? model(jsonEncode(response.data))
              : response.data,
          message: response.data['message'] ?? "",
        );
      } else {
        return ResponseModel(
          status: false,
          message: response.data['message'] ?? "",
        );
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return ResponseModel();
      }
      if (e.response != null) {
        final data = e.response!.data;
        final defaultMsg = ApiConstants.getErrorMsg(e.response!.statusCode);
        return ResponseModel(
          message: data is String
              ? defaultMsg
              : (data?["message"] ?? defaultMsg),
        );
      } else {
        return ResponseModel(
          status: false,
          message: StringConstants.kServerNotFound.tr,
        );
      }
    } catch (e) {
      return ResponseModel(status: false, message: e.toString());
    }
  }

  /// Sends a DELETE request using Dio and returns a standardized ResponseModel with success, data, and error handling.
  Future<ResponseModel> deleteRequest({
    required String url,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await Global.checkInternet()) {
      return ResponseModel();
    }
    try {
      final response = await dio.delete(
        url,
        queryParameters: queryParameters,
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data["success"]) {
        return ResponseModel(
          status: true,
          data: response.data,
          message: response.data['message'] ?? "",
        );
      } else {
        return ResponseModel(
          status: false,
          message: response.data['message'] ?? "",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        final defaultMsg = ApiConstants.getErrorMsg(e.response!.statusCode);
        return ResponseModel(
          message: data is String
              ? defaultMsg
              : (data?["message"] ?? defaultMsg),
        );
      } else {
        return ResponseModel(
          status: false,
          message: StringConstants.kServerNotFound.tr,
        );
      }
    } catch (e) {
      return ResponseModel(status: false, message: e.toString());
    }
  }

  /// Sends a PUT request using Dio and returns a standardized ResponseModel
  Future<ResponseModel> putRequest({
    required String url,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    File? file,
    String? fileKey = 'file',
    dynamic model,
    CancelToken? cancelToken,
  }) async {
    if (!await Global.checkInternet()) {
      return ResponseModel();
    }
    try {
      dynamic payload = body;
      if (file != null) {
        final fileName = file.path.split('/').last;
        payload = FormData.fromMap({
          ...?body,
          fileKey!: await MultipartFile.fromFile(file.path, filename: fileName),
        });
      }

      final response = await dio.put(
        url,
        data: payload,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options:
            options ??
            Options(
              headers: {
                'Content-Type': file != null
                    ? 'multipart/form-data'
                    : 'application/json',
              },
            ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data["success"]) {
        return ResponseModel(
          status: true,
          message: response.data["message"] ?? "",
          data: model != null
              ? model(jsonEncode(response.data))
              : response.data,
        );
      } else {
        return ResponseModel(message: response.data["message"] ?? "");
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return ResponseModel();
      }
      if (e.response != null) {
        final data = e.response!.data;
        final defaultMsg = ApiConstants.getErrorMsg(e.response!.statusCode);
        return ResponseModel(
          message: data is String
              ? defaultMsg
              : (data?["message"] ?? defaultMsg),
        );
      } else {
        return ResponseModel(
          status: false,
          message: StringConstants.kServerNotFound.tr,
        );
      }
    } catch (e) {
      return ResponseModel(status: false, message: e.toString());
    }
  }

  // ----  GET Request ----
  Future<ResponseModel> getRequest({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool showInternetMsg = false,
    dynamic model,
  }) async {
    if (!await Global.checkInternet(showMsg: showInternetMsg)) {
      return ResponseModel();
    }
    try {
      final response = await dio.get(url, queryParameters: queryParameters);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data["success"]) {
        return ResponseModel(
          status: true,
          data: model != null
              ? model(jsonEncode(response.data))
              : response.data,
          message: response.data['message'] ?? "",
        );
      } else {
        return ResponseModel(
          status: false,
          message: response.data['message'] ?? "",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        final defaultMsg = ApiConstants.getErrorMsg(e.response!.statusCode);
        return ResponseModel(
          message: data is String
              ? defaultMsg
              : (data?["message"] ?? defaultMsg),
        );
      } else {
        return ResponseModel(
          status: false,
          message: StringConstants.kServerNotFound.tr,
        );
      }
    } catch (e) {
      return ResponseModel(status: false, message: e.toString());
    }
  }
}




''',

    'lib/core/services/network/api_constants.dart': '''
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
''',

    'lib/core/constants/app_colors.dart': '''
import 'package:flutter/material.dart';
/// Defines a centralized set of app color constants for consistent styling.
class AppColors {
  static const Color cBlue = Colors.blue;
  static const Color cWhite = Colors.white;
  static const Color cBlack = Colors.black;
}
''',

    'lib/core/constants/app_font_size.dart': '''
/// Holds predefined font size constants for consistent typography across the app.
class AppFontSize {
  static const double font14 = 14;
  static const double font16 = 16;
  static const double font24 = 24;
}
''',

    'lib/core/constants/assets.dart': '''
/// Stores asset file path constants used throughout the application.
class Assets {
  static const String pngTriangleInsetHey =
      "assets/images/placeholder.png";
}
''',

    'lib/feature/splash/splash_page.dart': '''
import 'package:flutter/material.dart';
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
     return const Scaffold(body: Center(child: Text("Splash Screen")));
  }
}
''',

    'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:structure/core/routing/app_pages.dart';
import 'package:structure/core/routing/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
''',
    'lib/feature/splash/splash_controller.dart': '''
import 'package:get/get.dart';

class SplashController extends GetxController{
  
}    
''',

    /// -------------------- STORAGE --------------------
    'lib/core/storage/app_storage.dart': '''
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
''',

    /// -------------------- COMMON --------------------
    'lib/core/common/common_ui.dart': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/assets.dart';
import '../language/string_constants.dart';

/// Utility class providing reusable common UI widgets and helpers across the app.
class CommonUI {

/// Returns a customizable circular loading indicator with optional color and stroke width.
  static Widget circularIndicator({
    Color color=AppColors.cBlue,
    double strokeWidth=3,
  }) {
    return CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );
  }
  
  /// Method to return load more indicator.
  static Widget loadMoreIndicator({
    double? strokeWidth,
    Color? backgroundColor,
  }) {
    return SizedBox(
      height: 40,
      width: 40,
      child: CircularProgressIndicator(
        color: AppColors.cBlue,
        strokeWidth: strokeWidth ?? 3.0,
        backgroundColor: backgroundColor,
      ),
    );
  }
  
  /// Wraps the given widget with a pull-to-refresh indicator that triggers the provided refresh callback.
  static Widget refreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.cBlue,
      backgroundColor: AppColors.cWhite,
      child: child,
    );
  }
  
  /// Wrapper around SafeArea that applies platform-aware bottom padding and configurable top inset.
  static Widget safeArea({
    required Widget child,
    bool top = true,
  }) {
    return SafeArea(
      bottom: !GetPlatform.isIOS,
      top: top,
      child: child,
    );
  }
  
  /// Method to set network image
  static Widget setNetworkImg({
    String imgUrl = "",
    double height = 125,
    double width = 125,
    double borderRadius = 12,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(height: height, width: width, color: Colors.white),
          );
        },
        errorWidget: (context, url, error) {
          return Image.asset(
            Assets.pngTriangleInsetHey,
            height: height,
            width: width,
            fit: fit,
          );
        },
      ),
    );
  }
  
  /// Builds a customizable TextButton with left alignment, optional styling, and built-in haptic feedback and keyboard dismissal.
  static Widget customTextBtn({
    required String title,
    void Function()? onPressed,
    EdgeInsetsGeometry padding=EdgeInsets.zero,
    TextStyle? style,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        overlayColor: Colors.grey,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: padding,
        minimumSize: const Size(0, 0),
      ),
      onPressed: () {
        AppConstants.hapticFeedBack();
        AppConstants.hideKeyboard();
        onPressed?.call();
      },
      child: Text(
        title,
        style: style 
      ),
    );
  }
  

/// Displays a success or error snackBar with a trimmed message based on API response.
  static void showApiSnackBar({
    bool isSuccess = false,
    required String message,
  }) {
    final displayMessage =
        message.length > 200 ? "\${message.substring(0, 200)}..." : message;

    Get.snackbar(
      isSuccess ? StringConstants.kSuccess.tr : StringConstants.kError.tr,
      displayMessage,
      backgroundColor:
          isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      colorText: Colors.white,
    );
  }
}
''',

    /// -------------------- GLOBAL --------------------
    'lib/core/common/global.dart': '''
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
''',

    /// -------------------- EXTENSION --------------------
    'lib/core/extension/sized_box_extension.dart': '''
import 'package:flutter/material.dart';

/// Provides shorthand extensions to create SizedBox widgets for width and height spacing.
extension SizedBoxExt on num {
  SizedBox get w => SizedBox(width: toDouble());
  SizedBox get h => SizedBox(height: toDouble());
}
''',

    /// -------------------- LANGUAGE --------------------
    'lib/core/language/string_constants.dart': '''
/// Contains all app-wide string constants for messages, labels, and errors.    
class StringConstants {

  /// Internet
  static const String kCheckInternetConnection =
      "Check internet connection";

  /// Common
  static const String kSuccess = "Success";
  static const String kError = "Error";

  /// Errors
  static const String kSomethingWentWrong =
      "Something went wrong";
  static const String kServerNotFound =
      "Server not reachable. Please try again";
}
''',

    /// -------------------- ROUTING --------------------
    'lib/core/routing/app_pages.dart': '''
import 'package:get/get.dart';
import '../routing/app_routes.dart';
import '../../feature/splash/splash_page.dart';
import '../../feature/splash/splash_controller.dart';

/// Configures all application routes with their corresponding pages and bindings.
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SplashController())),
    ),
  ];
}
''',

    'lib/core/routing/app_routes.dart': '''
/// Defines all named route paths used for app navigation.
class AppRoutes {
  static const String splash = "/splash";
}
''',
  };

  // --- STEP 4: Write files sequentially after structure setup ---
  print('\n📝 Injecting codebase files...');
  for (var entry in filesWithContent.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
      print('📁 Created: ${entry.key}');
    } else {
      print('⏭ Skipped (Already Exists): ${entry.key}');
    }
  }

  print('\n✨ Project creation complete and structured beautifully!');
}

class Struct {
  static Future<void> addDependencies() async {
    final pubspecFile = File('pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      print('❌ Error: This script must run at the root of a Flutter project.');
      exit(1);
    }

    print('\n📦 Phase 1: Checking & Installing Dependencies...');

    // Read the current pubspec contents to prevent duplicate installs
    final pubspecContent = pubspecFile.readAsStringSync();

    final dependencies = [
      'get',
      'cached_network_image',
      'connecteo',
      'flutter_dotenv',
      'dio',
      'skeletonizer',
    ];

    for (var package in dependencies) {
      // Regex checks if the package exists as a standalone key under dependencies
      // It looks for the package name followed by a colon (e.g., "get:")
      final packagePattern = RegExp(
        r'^\s*' + RegExp.escape(package) + r'\s*:',
        multiLine: true,
      );

      if (pubspecContent.contains(packagePattern)) {
        print('  ⏭ Skipped: Package "$package" is already in pubspec.yaml');
      } else {
        await runCommand('flutter', ['pub', 'add', package]);
      }
    }

    print('✅ All context packages successfully configured in pubspec.yaml.\n');
  }

  static Future<void> runCommand(String command, List<String> args) async {
    // Keeping runInShell: true so it continues to work flawlessly on Windows
    final result = await Process.run(command, args, runInShell: true);

    if (result.exitCode == 0) {
      print('  ✔ Package Added: ${args.last}');
    } else {
      print('  ❌ Command execution failed: ${result.stderr}');
    }
  }
}
