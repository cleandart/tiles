import 'common/component.dart';
import 'utils/utils.dart';
import 'dart:html';

main() {
  var localSettings = getSettingsFromHash();
  if (localSettings["library"] == "react") {
    initReact();
  } else {
    initTiles();
  }


  Element element = querySelector("#container");
  var description = component(props: {"levels": localSettings["levels"], "level": 0, "prefix": "runner"});

  if (localSettings["environment"] == "virtual") {
    createVirtualDOM(description, element);
  } else {
    mountComponent(description, element);

    if (localSettings["update"] == true) {
      bool dirty = localSettings["dirty"];
      String benchmarkType = dirty ? Benchmark.DIRTYUPDATING : Benchmark.CLEANUPDATING;

      benchmark.prepareUpdate();
      benchmark.start(benchmarkType);
      update(dirty);
      benchmark.stop(benchmarkType);

    }
  }
  
  printResults();
}

