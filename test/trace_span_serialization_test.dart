import 'package:test/test.dart';
import 'package:tracer/trace_span.dart';

void main() {
  group('TraceSpan toJson', () {
    test('TraceSpan.named toJson', () {
      final spanName = "spanName";
      final span = TraceSpan.named(spanName);
      final json = span.toJson();
      expect(json, {
        "type": "named",
        "name": spanName,
        "spanId": span.spanId,
        "parrentSpanId": span.parrent?.spanId,
      });
    });

    test('TraceSpan.source toJson', () {
      final fnName = "FunctionName";
      final srcPath = "source path";
      final span = TraceSpan.source(fnName, srcPath);

      expect(span.toJson(), {
        "type": "source",
        "functionName": fnName,
        "srcPath": srcPath,
        "spanId": span.spanId,
        "parrentSpanId": span.parrent?.spanId,
      });
    });

    test('TraceSpan.sourceStack toJson', () {
      final fnName = "main.<anonymous closure>.<anonymous closure>";
      final span = TraceSpan.sourceStack(StackTrace.current, depth: 0);
      final json = span.toJson();

      expect(json, contains("srcPath"));
      expect(json, {
        "type": "source",
        "functionName": fnName,
        "srcPath": json["srcPath"],
        "spanId": span.spanId,
        "parrentSpanId": span.parrent?.spanId,
      });
    });

    test('TraceSpan.ref toJson', () {
      final spanId = 322;
      final span = TraceSpan.ref(spanId);
      final json = span.toJson();
      expect(span.spanId, spanId);
      expect(json, {"type": "ref", "spanId": span.spanId});
    });
  });

  group("TraceSpan fromJson", () {
    test("TraceSpan.named fromJson", () {
      final spanName = "spanName";
      final span = TraceSpan.named(spanName, spanId: 8);

      expect(TraceSpan.fromJson(span.toJson()), equals(span));

      final span2 = TraceSpan.named(
        spanName,
        spanId: 2,
        parrent: TraceSpan.named("bruh", spanId: 1),
      );

      expect(TraceSpan.fromJson(span2.toJson()), equals(span2));
      expect(TraceSpan.fromJson(span2.toJson()).parrent, isA<TraceSpanRef>());
    });

    test("TraceSpan.source fromJson", () {
      final fnName = "fnName";
      final srcPath = "srcPath";
      final span = TraceSpan.source(fnName, srcPath, spanId: 8);

      expect(TraceSpan.fromJson(span.toJson()), equals(span));

      final span2 = TraceSpan.source(
        fnName,
        srcPath,
        spanId: 2,
        parrent: TraceSpan.named("bruh", spanId: 1),
      );

      expect(TraceSpan.fromJson(span2.toJson()), equals(span2));
      expect(TraceSpan.fromJson(span2.toJson()).parrent, isA<TraceSpanRef>());
    });

    test("TraceSpan.ref fromJson", () {
      final span = TraceSpan.ref(33);

      expect(TraceSpan.fromJson(span.toJson()), equals(span));
    });
  });
}
