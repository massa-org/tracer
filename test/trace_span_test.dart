import 'dart:async';

import 'package:test/test.dart';
import 'package:tracer/trace_span.dart';

void main() {
  group("TraceSpan", () {
    test("trace span get parrent from zone", () {
      final parrent = TraceSpan.ref(22);
      runZoned(() {
        final span = TraceSpan.named("bruh");
        expect(span.parrent, parrent);
      }, zoneValues: {TraceSpan.zoneKey: parrent});
    });
  });
}
