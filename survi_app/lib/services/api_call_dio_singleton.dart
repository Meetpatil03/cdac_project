import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_prefs_cookie_store/shared_prefs_cookie_store.dart';

class APICall {
  // Dio instance for making HTTP requests
  final Dio _dio;

  // cookie store to persist cookie across sessions
  final SharedPrefCookieStore _cookieStore = SharedPrefCookieStore();

  // singleton instance
  static final APICall _instance = APICall._internal();

  // Factory Contructor
  factory APICall() => _instance;

  // Private Constructor
  APICall._internal() : _dio = Dio() {
    init(); // initialie Dio with interceptors
  }

  // intitialize fucntion to setpu Dio with internceptors
  void init() {
    // Add CookieManager to Dio to automatically manage cookies
    _dio.interceptors.add(CookieManager(_cookieStore));

    // Add logging and error handling vial interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Sending request to ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print('Error occurred : $error');
          return handler.next(error);
        },
      ),
    );
  }

  void clearCookies() {
    _cookieStore.deleteAll();
  }

  Dio get client => _dio;
}
