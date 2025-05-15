import 'package:test/test.dart';
import 'package:tracer/trace_span.dart';

void main() {
  group("TraceSpan equality", () {
    final trace = StackTrace.current;
    final spanSourceStack = TraceSpanSourceStack(trace, spanId: 27);

    final data = [
      [
        "ref",
        [TraceSpan.ref(322), TraceSpan.ref(322)],
        [TraceSpan.ref(1)],
      ],
      [
        "named",
        [
          TraceSpan.named("hello", spanId: 0),
          TraceSpan.named("hello", spanId: 0),
        ],
        [
          TraceSpan.named("hllo", spanId: 0),
          TraceSpan.named("hello", spanId: 1),
          TraceSpan.named("hello", spanId: 0, parrent: TraceSpan.ref(2)),
        ],
      ],
      [
        "named_with_parrent",
        [
          TraceSpan.named("hello", spanId: 0, parrent: TraceSpan.ref(32)),
          TraceSpan.named("hello", spanId: 0, parrent: TraceSpan.ref(32)),
        ],
        [TraceSpan.named("hello", spanId: 0, parrent: TraceSpan.ref(2))],
      ],
      [
        "source",
        [
          TraceSpan.source("functionName", "srcPath", spanId: 27),
          TraceSpan.source("functionName", "srcPath", spanId: 27),
        ],
        [
          TraceSpan.source("_functionName", "srcPath", spanId: 27),
          TraceSpan.source("functionName", "srcPath", spanId: 28),
          TraceSpan.source(
            "functionName",
            "srcPath",
            spanId: 27,
            parrent: TraceSpan.ref(2),
          ),
        ],
      ],
      [
        "source_with_parrent",
        [
          TraceSpan.source(
            "functionName",
            "srcPath",
            spanId: 27,
            parrent: TraceSpan.ref(32),
          ),
          TraceSpan.source(
            "functionName",
            "srcPath",
            spanId: 27,
            parrent: TraceSpan.ref(32),
          ),
        ],
        [
          TraceSpan.source(
            "_functionName",
            "srcPath",
            spanId: 27,
            parrent: TraceSpan.ref(32),
          ),
          TraceSpan.source(
            "functionName",
            "srcPath",
            spanId: 28,
            parrent: TraceSpan.ref(32),
          ),
          TraceSpan.source(
            "functionName",
            "srcPath",
            spanId: 27,
            parrent: TraceSpan.ref(2),
          ),
        ],
      ],
      [
        "source stack",
        [
          spanSourceStack,
          spanSourceStack.intoSourceSpan(),
          TraceSpan.sourceStack(trace, spanId: 27),
        ],
        [
          TraceSpan.sourceStack(trace, spanId: 29),
          TraceSpan.sourceStack(trace, spanId: 29, parrent: TraceSpan.ref(32)),
        ],
      ],
    ];
    for (final [name, eq, neq] in data) {
      test("TraceSpan $name equality", () {
        for (final s0 in eq as Iterable) {
          for (final s1 in eq) {
            expect(s0, equals(s1));
          }
          for (final s1 in neq as Iterable) {
            expect(s0, isNot(equals(s1)));
          }
        }
      });
    }
  });
}
