class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NoConnectionException extends AppException {
  NoConnectionException()
      : super(
            'No internet connection. Please check your connection and try again.');
}

class TimeoutException extends AppException {
  TimeoutException() : super('The request timed out. Please try again later.');
}

class UnauthorizedException extends AppException {
  final dynamic data;
  UnauthorizedException(this.data)
      : super('You are not authorized to access this content. Please log in.');
}

class ForbiddenException extends AppException {
  final dynamic data;
  ForbiddenException(this.data)
      : super('Access is forbidden. You don\'t have permissions to proceed.');
}

class NotFoundException extends AppException {
  final dynamic data;
  NotFoundException(this.data) : super('The requested resource was not found.');
}

class ServerException extends AppException {
  final dynamic data;
  ServerException(this.data)
      : super('An internal server error occurred. Please try again later.');
}

class BadRequestException extends AppException {
  final dynamic data;
  BadRequestException(this.data)
      : super('The request is invalid. Please check your input and try again.');
}

class RequestCancelledException extends AppException {
  RequestCancelledException() : super('The request has been cancelled.');
}

class UnexpectedException extends AppException {
  UnexpectedException() : super("Something went wrong. Please try again.");
}
