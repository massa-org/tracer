import 'dart:async';

sealed class TraceSpan {
  factory TraceSpan.named(String name, {int? spanId, TraceSpan? parrent}) =
      TraceSpanNamed;
  factory TraceSpan.source(
    String functionName,
    String srcPath, {
    int? spanId,
    TraceSpan? parrent,
  }) = TraceSpanSource;
  factory TraceSpan.ref(int spanId) = TraceSpanRef;

  factory TraceSpan.sourceStack(
    StackTrace trace, {
    int depth,
    int? spanId,
    TraceSpan? parrent,
  }) = TraceSpanSourceStack;

  TraceSpan({TraceSpan? parrent, int? spanId})
    : spanId = spanId ?? currentSpanId++,
      parrent = parrent ?? TraceSpan.current;

  final TraceSpan? parrent;
  final int spanId;

  static int currentSpanId = 0;

  static const Symbol zoneKey = #currentSpan;
  static TraceSpan? get current => Zone.current[zoneKey];

  Map<String, dynamic> toJson() => {
    "spanId": spanId,
    "parrentSpanId": parrent?.spanId,
  };

  /// restore trace span fromJson
  /// restored trace span is not equal to original span
  /// cause parrent span is replaced with ref TraceSpan.ref(parrent.spanId)
  factory TraceSpan.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        "named" => TraceSpanNamed.fromJson(json),
        "source" => TraceSpanSource.fromJson(json),
        "ref" => TraceSpanRef.fromJson(json),
        _ => throw UnimplementedError(),
      };

  /// check if spans equals by ref, i.e. spanId is equal to other
  bool refEqual(TraceSpan other) => spanId == other.spanId;

  /// util to convert this span to ref span
  TraceSpan toRef() => TraceSpan.ref(spanId);

  /// span equality, two spans are equal
  /// if their params match and they parrentSpan refEqual
  /// hashCode must use parrent.spanId in hash
  /// TraceSpanSourceStack equality checks after conversion into TraceSpanSource
}

class TraceSpanNamed extends TraceSpan {
  TraceSpanNamed(this.name, {super.parrent, super.spanId}) : super();

  final String name;

  @override
  Map<String, dynamic> toJson() => {
    "type": "named",
    "name": name,
    ...super.toJson(),
  };

  @override
  factory TraceSpanNamed.fromJson(Map<String, dynamic> json) {
    final parrent = json["parrentSpanId"] as int?;
    return TraceSpanNamed(
      json["name"],
      parrent: parrent == null ? null : TraceSpan.ref(parrent),
      spanId: json["spanId"],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceSpanNamed &&
        other.name == name &&
        other.spanId == spanId &&
        (parrent == null && other.parrent == null ||
            parrent!.refEqual(other.parrent!));
  }

  @override
  int get hashCode => Object.hash(name, spanId, parrent?.spanId);

  @override
  String toString() =>
      'TraceSpan.named("$name",spanId: $spanId,parrent: ${parrent?.spanId})';
}

class TraceSpanSource extends TraceSpan {
  TraceSpanSource(
    this.functionName,
    this.srcPath, {
    super.parrent,
    super.spanId,
  });

  final String functionName;
  final String srcPath;

  @override
  Map<String, dynamic> toJson() => {
    "type": "source",
    "functionName": functionName,
    "srcPath": srcPath,
    ...super.toJson(),
  };

  @override
  factory TraceSpanSource.fromJson(Map<String, dynamic> json) {
    final parrent = json["parrentSpanId"] as int?;
    return TraceSpanSource(
      json["functionName"],
      json["srcPath"],
      parrent: parrent == null ? null : TraceSpan.ref(parrent),
      spanId: json["spanId"],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is TraceSpanSourceStack) other = other.intoSourceSpan();

    return other is TraceSpanSource &&
        other.functionName == functionName &&
        other.srcPath == srcPath &&
        other.spanId == spanId &&
        (parrent == null && other.parrent == null ||
            parrent!.refEqual(other.parrent!));
  }

  @override
  int get hashCode =>
      Object.hash(functionName, srcPath, spanId, parrent?.spanId);

  @override
  String toString() =>
      'TraceSpan.source("$functionName","$srcPath",spanId: $spanId,parrent: ${parrent?.spanId})';
}

class TraceSpanSourceStack extends TraceSpan {
  TraceSpanSourceStack(
    this.trace, {
    this.depth = 0,
    super.parrent,
    super.spanId,
  });

  final int depth;
  final StackTrace trace;

  String? _functionName;
  String? _srcPath;

  void _materialize() {
    if (_functionName != null) return;
    final line = trace.toString().split('\n')[depth];

    // TODO: fragile design, maybe is good to add error when stack line does't match with regex
    final match = RegExp("#\\d+\\s+(.+)\\s+\\((.+)\\)").firstMatch(line);
    _functionName = (match?[1] ?? '');
    _srcPath = (match?[2] ?? '');
  }

  TraceSpanSource intoSourceSpan() {
    _materialize();
    return TraceSpanSource(
      _functionName!,
      _srcPath!,
      parrent: parrent,
      spanId: spanId,
    );
  }

  @override
  Map<String, dynamic> toJson() => intoSourceSpan().toJson();

  @override
  String toString() {
    _materialize();
    return 'TraceSpan.sourceStack("$_functionName","$_srcPath",spanId: $spanId,parrent: ${parrent?.spanId})';
  }

  @override
  bool operator ==(Object other) {
    return intoSourceSpan() == other;
  }

  @override
  int get hashCode => intoSourceSpan().hashCode;
}

class TraceSpanRef extends TraceSpan {
  TraceSpanRef(int spanId) : super(spanId: spanId);

  @override
  Map<String, dynamic> toJson() => {"type": "ref", "spanId": spanId};

  @override
  factory TraceSpanRef.fromJson(Map<String, dynamic> json) {
    return TraceSpanRef(json["spanId"]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceSpanRef && other.spanId == spanId;
  }

  @override
  int get hashCode => spanId;

  @override
  String toString() => 'TraceSpan.ref(spanId: $spanId)';
}
