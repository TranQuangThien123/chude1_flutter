import 'dart:async';

/// A custom [StreamTransformer] implementing the Debounce pattern in pure Dart.
///
/// It suppresses events until a specified [duration] of silence has passed,
/// emitting only the latest item. Crucial for real-time search inputs and high-frequency feeds.
class DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;

  DebounceStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    Timer? timer;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (controller != null && !controller.isClosed) {
                controller.add(data);
              }
            });
          },
          onError: (error, stackTrace) {
            if (controller != null && !controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            // Wait for pending debounce before closing
            if (timer != null && timer!.isActive) {
              timer?.cancel();
            }
            if (controller != null && !controller.isClosed) {
              controller.close();
            }
          },
          cancelOnError: false,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        timer?.cancel();
        return subscription?.cancel();
      },
      sync: true,
    );

    return controller.stream;
  }
}

/// A custom [StreamTransformer] implementing the Throttle pattern.
///
/// Emits the first item, then ignores all items for the duration of the throttle window.
class ThrottleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;

  ThrottleStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    bool isThrottling = false;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (data) {
            if (!isThrottling) {
              isThrottling = true;
              if (controller != null && !controller.isClosed) {
                controller.add(data);
              }
              Timer(duration, () {
                isThrottling = false;
              });
            }
          },
          onError: (error, stackTrace) {
            if (controller != null && !controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            if (controller != null && !controller.isClosed) {
              controller.close();
            }
          },
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel(),
      sync: true,
    );

    return controller.stream;
  }
}

/// Extension methods on [Stream] providing fluent syntax for stream operators.
extension StreamTransformationExtensions<T> on Stream<T> {
  /// Delays emitting items until [duration] has elapsed since the last emitted item.
  Stream<T> customDebounce(Duration duration) {
    return transform(DebounceStreamTransformer<T>(duration));
  }

  /// Emits first item, then silences emissions for [duration].
  Stream<T> customThrottle(Duration duration) {
    return transform(ThrottleStreamTransformer<T>(duration));
  }
}
