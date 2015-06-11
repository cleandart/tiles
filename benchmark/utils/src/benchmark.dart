part of utils;

class Benchmark {
  num toRender = 0;
  num rendered = 0;

  static const ALLRENDERED = "All rendered";
  static const VIRTUALDOMBUILDING = "Virtual DOM building";
  static const MOUNTING = "Mounting to element";
  static const CLEANUPDATING = "CLEAN UPDATING";
  static const DIRTYUPDATING = "DIRTY UPDATING";
  Stopwatch stopwatch;
  Benchmark() {
    stopwatch = new Stopwatch()..start();
    durations = {};
  }
  Map<String, _Duration> durations;

  start(String what) {
    _Duration duration = durations[what];
    if (duration == null) {
      durations[what] = duration = new _Duration();
    }

    duration.begin = stopwatch.elapsedMilliseconds;
  }

  stop(String what) {
    _Duration duration = durations[what];
    if (duration == null) {
      durations[what] = duration = new _Duration();
    }
    duration.end = stopwatch.elapsedMilliseconds;
  }

  toString() =>
      "${durations[MOUNTING]},${durations[VIRTUALDOMBUILDING]},${durations[ALLRENDERED]},${durations[CLEANUPDATING]},${durations[DIRTYUPDATING]}";

  print(var printer) {
    printer(this.toString());
  }

  prepareUpdate() {
    toRender = 1;
    rendered = 0;
  }
}

class _Duration {
  num begin;
  num end;
  String toString() {
    if (begin != null && end != null) {
      return "${end - begin}";
    }
    if (begin != null) {
      return "END is null";
    }
    if (end != null) {
      return "BEGIN is null";
    }
  }
}
