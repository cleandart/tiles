library tiles_benchmark_mass;

import '../utils/wrapper.dart';

class Mass extends Component {
  Mass([props, children]): super(props, children);
  
  render() {
    var children = [];
    for(var i = 0; i < 1000; ++i) {
      children.add(div(children: "child $i", key: "child$i"));
    }
    return div(children: children);
  }
}

var mass = registerComponent(({props, children}) => new Mass(props, children));