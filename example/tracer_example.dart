import 'package:tracer/tracer.dart';

final inMemCollector = TraceCollectorInMemory();
final t = Tracer([TraceCollectorPrinter(), inMemCollector].merge);

void doAction() => t.withSpan(() {
  t.trace("trace");
  t.verbose("verbose");
  t.debug("debug");
  t.info("info");
  t.log("log");
  t.warn("warn");
  t.error("error", error: UnimplementedError(), params: {#param: 322});
  t.critical("critical");
  t.fatal("fatal");

  t.event("custom_event");
});

void main() {
  t.info("hello");
  t.withSpan(doAction);

  print(inMemCollector.entries.length);
}
