
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
          options.headers['Authorization'] = 'Bearer $token';
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




