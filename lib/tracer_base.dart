import 'dart:async';

import 'trace_collector.dart';
import 'trace_entry.dart';

/// base class for tracer implementation, that handle boilerplate for different trace types
abstract class TracerBase {
  void addTraceEntry(TraceEntry entry);

  void Function(
    String? message, {
    Map<Symbol, dynamic>? params,
    dynamic error,
    StackTrace? stackTrace,
    TraceSpan? span,
  })
  createTraceFn(TraceEntryType type) {
    return (
      String? message, {
      Map<Symbol, dynamic>? params,
      dynamic error,
      StackTrace? stackTrace,
      TraceSpan? span,
    }) => addTraceEntry(
      TraceEntry(
        type: type,
        message: message,
        span: span ?? TraceSpan.current,
        params: params,
        error: error,
        stackTrace: stackTrace,
        timestamp: DateTime.now(),
      ),
    );
  }

  late final trace = createTraceFn(TraceEntryType.trace);
  late final verbose = createTraceFn(TraceEntryType.verbose);
  late final debug = createTraceFn(TraceEntryType.debug);
  late final info = createTraceFn(TraceEntryType.info);
  late final log = createTraceFn(TraceEntryType.log);
  late final warn = createTraceFn(TraceEntryType.warn);
  late final error = createTraceFn(TraceEntryType.error);
  late final fatal = createTraceFn(TraceEntryType.fatal);
  late final critical = createTraceFn(TraceEntryType.critical);

  late final event = createTraceFn(TraceEntryType.event);

  R withSpan<R>(R Function() fn, {String? spanName}) {
    final span =
        spanName != null
            ? TraceSpan.named(spanName)
            : TraceSpan.source(StackTrace.current, depth: 1);
    event('span_open', span: span);

    final result = runZoned(fn, zoneValues: {TraceSpan.zoneKey: span});
    if (result is Future) {
      result.whenComplete(() => event('span_close', span: span));
    } else {
      event('span_close', span: span);
    }
    return result;
  }
}

/// noop implementation, do nothing with trace entries
class NoopTracer extends TracerBase {
  @override
  void Function(
    String? message, {
    dynamic error,
    Map<Symbol, dynamic>? params,
    TraceSpan? span,
    StackTrace? stackTrace,
  })
  createTraceFn(TraceEntryType type) {
    return (
      String? message, {
      Map<Symbol, dynamic>? params,
      dynamic error,
      StackTrace? stackTrace,
      TraceSpan? span,
    }) {};
  }

  @override
  void addTraceEntry(TraceEntry entry) {}
}

/// default tracer implementation that pass trace entries to collector
class Tracer extends TracerBase {
  Tracer(this.collector);

  final TraceCollector collector;

  @override
  void addTraceEntry(TraceEntry entry) => collector.addTraceEntry(entry);
}
