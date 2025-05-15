import 'package:tracer/trace_span.dart';

import 'trace_entry.dart';

/// end point for hanlding trace entries, where all logic must be implemented
///   for ex. print, collect, etc
abstract class TraceCollector {
  void addTraceEntry(TraceEntry entry);
}

/// [print] entries into stdout with format and colors
class TraceCollectorPrinter implements TraceCollector {
  /// control sequences for terminal styles
  static const sgr = (
    reset: "[0m",
    text: (
      normal: (
        black: "[30m",
        red: "[31m",
        green: "[32m",
        yellow: "[33m",
        blue: "[34m",
        purple: "[35m",
        cyan: "[36m",
        white: "[37m",
      ),
      bold: (
        black: "[1;30m",
        red: "[1;31m",
        green: "[1;32m",
        yellow: "[1;33m",
        blue: "[1;34m",
        purple: "[1;35m",
        cyan: "[1;36m",
        white: "[1;37m",
      ),
    ),
  );

  /// styles based on entry type
  final styles = {
    'event': sgr.text.normal.black,
    'info': sgr.text.normal.blue,
    'warn': sgr.text.normal.yellow,
    'error': sgr.text.normal.red,
    'fatal': sgr.text.bold.red,
  };

  String formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}"
        ":${timestamp.minute.toString().padLeft(2, '0')}"
        ":${timestamp.second.toString().padLeft(2, '0')}"
        ".${timestamp.millisecond.toString().padLeft(3, '0')}${timestamp.microsecond.toString().padLeft(3, '0')}";
  }

  String? formatSpan(TraceSpan? span) {
    return "@${span?.spanId}";
  }

  String? formatSpanByFunctionName(TraceSpan? span) {
    if (span == null) return null;
    final name = switch (span) {
      TraceSpanSource(:final functionName) => functionName,
      TraceSpanSourceStack(:final depth, :final trace) =>
        trace.toString().split('\n')[depth].split(RegExp('\\s+'))[1],
      TraceSpanNamed(:final name) => name,
      TraceSpanRef() => '_',
    };

    return [formatSpanByFunctionName(span.parrent), name].nonNulls.join(' > ');
  }

  @override
  void addTraceEntry(TraceEntry entry) {
    final message = [
      [
        formatTimestamp(entry.timestamp),
        entry.type.type,
        formatSpanByFunctionName(entry.span),
        entry.message,
      ].nonNulls.join('\t'),
      entry.params?.toString(),
      entry.error?.toString(),
      entry.stackTrace?.toString(),
    ].nonNulls.join('\n');

    print("${styles[entry.type.type] ?? ''}$message${sgr.reset}");
  }
}

/// just save all entries into list
class TraceCollectorInMemory implements TraceCollector {
  final List<TraceEntry> entries = [];

  @override
  void addTraceEntry(TraceEntry entry) => entries.add(entry);
}

class TraceCollectorMerge implements TraceCollector {
  TraceCollectorMerge(List<TraceCollector> collectors)
    : collectors = List.unmodifiable(collectors);

  final List<TraceCollector> collectors;

  @override
  void addTraceEntry(TraceEntry entry) {
    for (final collector in collectors) {
      collector.addTraceEntry(entry);
    }
  }
}

extension TraceCollectorMergeExtension on List<TraceCollector> {
  /// merge multiple collectors and call it one by one
  TraceCollector get merge => TraceCollectorMerge(this);
}
