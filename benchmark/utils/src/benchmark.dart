part of utils;

class Benchmark {
  static const VIRTUALDOMBUILDING = "Virtual DOM building"; 
  static const MOUNTING = "Mounting to element";
  Stopwatch stopwatch;
  Benchmark() {
    stopwatch = new Stopwatch()..start();
    durations = {};
  }
  Map<String, _Duration> durations;
  
  start(String what) {
    _Duration duration = durations[what];
    if(duration == null) {
      durations[what] = duration = new _Duration();
    }
    
    duration.begin = stopwatch.elapsedMilliseconds;
  }
  
  stop(String what) {
    _Duration duration = durations[what];
    if(duration == null) {
      durations[what] = duration = new _Duration();
    }
    duration.end = stopwatch.elapsedMilliseconds;
  }
  
  toString() => "${durations[MOUNTING]}, ${durations[VIRTUALDOMBUILDING]}";
  
  print(var printer) {
    printer(this.toString());
  }
}

class _Duration {
  num begin;
  num end;
  String toString() => begin != null && end != null ? "${end - begin}" : "Not COMPLETE!!!";
}