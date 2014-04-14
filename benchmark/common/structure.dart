library tiles_benchmark_mass;

import '../utils/wrapper.dart';

class Structure extends Component {
  Map props;
  
  Structure([this.props, children]): super(null, children);
  
  render() {
    var children = [];
    if (this.props["count"] == 0) {
      return div(children: "leaf ${this.props["prefix"]}");
    }
    for(var i = 0; i < this.props["count"]; ++i) {
      
      children.add(structure(props: {"count": this.props["count"]- 1, "prefix": "${this.props["prefix"]}.$i"})); 
      
    }
    return div(children: children);
  }
}

var structure = registerComponent(({props, children}) => new Structure(props, children));