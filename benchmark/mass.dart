library tiles_benchmark_mass;

import './wrapper.dart';

class Mass extends Component {
  Mass([props, children]): super(props, children);
  
  render() {
    return div(children: [
      span(children: "ahoj")
    ]);
  }
}

var mass = registerComponent(({props, children}) => new Mass(props, children));