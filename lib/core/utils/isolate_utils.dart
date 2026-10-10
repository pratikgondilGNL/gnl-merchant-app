import 'dart:isolate';

/// Utility for offloading heavy computations to a separate isolate.
class IsolateUtils {
  IsolateUtils._();

  /// Runs [computation] in a separate isolate with [message] and returns the result.
  static Future<R> compute<R, T>(Future<R> Function(T message) computation, T message) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      (message) async {
        final sendPort = message[0] as SendPort;
        final data = message[1] as T;
        final result = await computation(data);
        sendPort.send(result);
      },
      [receivePort.sendPort, message],
    );
    return await receivePort.first as R;
  }
}
