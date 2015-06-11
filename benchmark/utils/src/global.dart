part of utils;

Map settings = {
  "levels": [1, 1],
  "lib": "tiles",
  "environment": "DOM",
  "dirty": false,
  "update": true
};

String _USED;
const String _TILES = "tiles";
const String _REACT = "react";

Logger logger = new Logger('benchmark');
Logger loggerTiles = new Logger('benchmark.tiles');
Logger loggerReact = new Logger('benchmark.react');
Benchmark reactBenchmark = new Benchmark();
Benchmark tilesBenchmark = new Benchmark();

printResults() {
  benchmark.print(window.console.log);
}

Map getSettingsFromHash() {
  String hash;
  if (window.location.hash.length > 1) {
    hash = window.location.hash.substring(1);
  } else {
    hash = "{}";
  }

  var json = JSON.decode(hash);
//  window.console.log("${json["levels"][2]}");

  Map result = {};

  _parseInput(
      json, result, ["levels", "library", "environment", "update", "dirty"]);

  return result;
}

_parseInput(dynamic json, Map result, List<String> whats) {
  for (String what in whats) {
    if (json[what] != null) {
      result[what] = json[what];
    } else {
      result[what] = settings[what];
    }
  }
}
