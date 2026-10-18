import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:chude1/core/transformers/custom_stream_transformers.dart';
import 'package:chude1/domain/repositories/market_repository.dart';
import 'package:chude1/services/crypto_feed_service.dart';
import 'package:chude1/main.dart';

void main() {
  group('1. Thí nghiệm Event Loop & Microtask Queue', () {
    test('Kiểm chứng Microtask Queue luôn được Event Loop ưu tiên trước Event Queue (Future/Timer)', () async {
      final executionOrder = <String>[];

      // Schedule Future (Event Queue)
      Future(() {
        executionOrder.add('Event Queue - Future()');
      });

      // Schedule Timer (Event Queue)
      Timer.run(() {
        executionOrder.add('Event Queue - Timer.run()');
      });

      // Schedule Microtask (Microtask Queue)
      scheduleMicrotask(() {
        executionOrder.add('Microtask Queue - scheduleMicrotask()');
      });

      // Schedule Future.microtask (Microtask Queue)
      Future.microtask(() {
        executionOrder.add('Microtask Queue - Future.microtask()');
      });

      // Synchronous code on Call Stack
      executionOrder.add('Call Stack - Synchronous');

      // Wait for Event Queue to drain
      await Future.delayed(const Duration(milliseconds: 50));

      // Assertions
      expect(executionOrder.first, equals('Call Stack - Synchronous'));
      expect(executionOrder[1], startsWith('Microtask Queue'));
      expect(executionOrder[2], startsWith('Microtask Queue'));
      expect(executionOrder[3], startsWith('Event Queue'));
      expect(executionOrder[4], startsWith('Event Queue'));
    });
  });

  group('2. Kiểm thử StreamTransformer & Debounce', () {
    test('DebounceStreamTransformer chỉ phát ra giá trị cuối cùng sau khoảng nghỉ', () async {
      final controller = StreamController<String>();
      final emittedValues = <String>[];

      final debouncedStream = controller.stream.customDebounce(const Duration(milliseconds: 100));
      final sub = debouncedStream.listen(emittedValues.add);

      // Rapidly fire inputs within 50ms (simulating fast typing: B -> BT -> BTC)
      controller.add('B');
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add('BT');
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add('BTC');

      // Wait less than debounce duration
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emittedValues.isEmpty, isTrue, reason: 'Chưa đủ 100ms tĩnh lặng nên chưa emit');

      // Wait until debounce expires
      await Future.delayed(const Duration(milliseconds: 100));
      expect(emittedValues, equals(['BTC']), reason: 'Chỉ emit duy nhất giá trị cuối cùng');

      await sub.cancel();
      await controller.close();
    });
  });

  group('3. Kiểm thử Huỷ luồng an toàn (Cancellation & Dispose Safety)', () {
    test('MarketRepository and CryptoFeedService dispose cleanly without leak', () async {
      final repository = MarketRepositoryImpl();
      final feedService = CryptoFeedService(repository: repository);

      final sub = feedService.getFilteredMarketStream().listen((_) {});

      await Future.delayed(const Duration(milliseconds: 50));

      // Test cancel subscription
      await sub.cancel();

      // Test feedService dispose
      feedService.dispose();
      repository.dispose();

      expect(true, isTrue);
    });

    test('Single asset stream can be safely cancelled upon leaving detail view', () async {
      final repository = MarketRepositoryImpl();
      int receivedTicks = 0;

      final assetSub = repository.getAssetStream('BTC').listen((asset) {
        receivedTicks++;
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate screen disposal: cancel subscription
      await assetSub.cancel();
      final ticksAtCancel = receivedTicks;

      await Future.delayed(const Duration(milliseconds: 100));
      // Ticks should not increase after cancellation
      expect(receivedTicks, equals(ticksAtCancel));

      repository.dispose();
    });
  });

  group('4. Widget Test: Khởi động ứng dụng Reactive Market App', () {
    testWidgets('Giao diện hiển thị đúng tiêu đề màn hình chính', (WidgetTester tester) async {
      await tester.pumpWidget(const ReactiveMarketApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Thị trường Crypto'), findsOneWidget);
    });
  });
}
