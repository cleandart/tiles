library tiles_benchmark_component;

import '../utils/utils.dart';

var update;

bool redrawing = false;

class BenchmarkComponent extends Component {
  Map props;
  
  String prefix;
  String me;
  num level;

  BenchmarkComponent([this.props, children]): super(null, children) {
    me = "";
  }
  
  render() {
    List levels = props["levels"];
    level = props["level"];
    prefix = props["prefix"] + me;

    if (levels.length <= level) {
      return div(children: "i am ${prefix}", key: prefix);
    }

    num number = levels[level];

    var children = [];
    if (levels.length == level+1) {
      for (var i = 0; i < number; ++i) {
        children.add(div(children: "i am $prefix.$i", key: i));
      }
    } else {
      for (var i = 0; i < number; ++i) {
        children.add(component(props: {
          "levels": levels,
          "level": level + 1,
          "prefix": prefix + ".$i"
        }, key: "child$i"));
      }
    }

    ++benchmark.rendered;
    if (benchmark.rendered == benchmark.toRender) {
      if (!redrawing) {
        benchmark.stop(Benchmark.ALLRENDERED);
      }
    }
    
    if (level == 0) {
      update = this.redraw;
    }

    return div(children: children);
  }
  
  redraw([bool dirty = false]) {
    redrawing = true;
    if (dirty) {
      me = "Updated is ";
    }
    super.redraw();
  }
  
}

var registeredComponent = registerComponent(({props, children}) => new BenchmarkComponent(props, children));

var component = ({props, children, key, Map listeners}) {
  ++benchmark.toRender;
  return registeredComponent(props: props, children: children, key: key, listeners: listeners);
};
