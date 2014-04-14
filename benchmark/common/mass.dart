library tiles_benchmark_mass;

import '../utils/wrapper.dart';

class Mass extends Component {
  Map props;
  
  Mass([this.props, children]): super(null, children);
  
  render() {
    var children = [];
    for(var i = 0; i < this.props["count"]; ++i) {
      children.add(div(children: "child $i", key: "child$i"));
    }
    return div(children: children);
  }
}

var mass = registerComponent(({props, children}) => new Mass(props, children));