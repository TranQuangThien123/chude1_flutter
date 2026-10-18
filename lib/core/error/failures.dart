/// Base class for all domain & data exceptions in the application.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException [$code]: $message';
}

/// Thrown when an asynchronous operation exceeds the allowed timeout limit.
class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException([super.message = 'Thao tác bất đồng bộ quá thời gian chờ (Timeout)'])
      : super(code: 'TIMEOUT_ERROR');
}

/// Thrown when attempting to push events to or read from a closed StreamController.
class StreamClosedException extends AppException {
  const StreamClosedException([super.message = 'StreamController đã bị hủy/đóng (Disposed/Closed)'])
      : super(code: 'STREAM_CLOSED');
}

/// Thrown when real-time data cannot be parsed.
class DataParsingException extends AppException {
  const DataParsingException(super.message, {super.details})
      : super(code: 'PARSING_ERROR');
}
