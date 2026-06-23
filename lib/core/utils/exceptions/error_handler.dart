import 'dart:io';

import 'package:azan/core/utils/exceptions/app_exceptions.dart';
import 'package:dio/dio.dart';

class ExceptionHandler {
  static AppException handleException(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode == 401) return UnauthorizedException(data);
          if (statusCode == 403) return ForbiddenException(data);
          if (statusCode == 404) return NotFoundException(data);
          if (statusCode != null && statusCode >= 500) {
            return ServerException(data);
          }
          return BadRequestException(data);
        case DioExceptionType.cancel:
          return RequestCancelledException();
        case DioExceptionType.unknown:
          return NoConnectionException();
        default:
          return AppException('Unknown network error: ${error.message}');
      }
    } else if (error is SocketException) {
      return NoConnectionException();
    } else {
      print(error.toString());
      return UnexpectedException();
    }
  }
}
