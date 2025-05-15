import 'package:tracer/trace_span.dart';

/// represent type of tracing entry, basicly is log level
class TraceEntryType {
  const TraceEntryType.custom(this.type, this.level);

  final String type;
  final int level;

  static const trace = TraceEntryType.custom('trace', 0);
  static const verbose = TraceEntryType.custom('trace', 0);
  static const debug = TraceEntryType.custom('debug', 1);
  static const info = TraceEntryType.custom('info', 2);
  static const log = TraceEntryType.custom('info', 2);
  static const warn = TraceEntryType.custom('warn', 3);
  static const error = TraceEntryType.custom('error', 4);
  static const critical = TraceEntryType.custom('fatal', 5);
  static const fatal = TraceEntryType.custom('fatal', 5);

  static const event = TraceEntryType.custom('event', 0);

  static const values = [
    trace,
    verbose,
    debug,
    info,
    log,
    warn,
    error,
    critical,
    fatal,
    event,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TraceEntryType && other.type == type;

  @override
  int get hashCode => Object.hash(runtimeType, type.hashCode);

  String toJson() => type;

  factory TraceEntryType.fromJson(String type) => switch (type) {
    "trace" => TraceEntryType.trace,

    "debug" => TraceEntryType.debug,
    "info" => TraceEntryType.info,

    "warn" => TraceEntryType.warn,
    "error" => TraceEntryType.error,
    "fatal" => TraceEntryType.fatal,
    "event" => TraceEntryType.event,
    String type => TraceEntryType.custom(type, 0),
  };
}

class TraceEntry {
  const TraceEntry({
    required this.type,
    required this.message,
    required this.span,
    required this.params,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
  });

  final TraceEntryType type;
  final String? message;
  final TraceSpan? span;

  final Map<Symbol, dynamic>? params;

  final dynamic error;
  final StackTrace? stackTrace;

  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceEntry &&
          other.type == type &&
          other.message == message &&
          other.span == span &&
          other.params == params &&
          other.error == error &&
          other.stackTrace == stackTrace &&
          other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    message,
    span,
    params,
    error,
    stackTrace,
    timestamp,
  );
}
