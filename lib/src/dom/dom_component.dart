part of tiles;

class DomComponent extends Component {
  final String tagName;
  final bool pair;

  Map _props;

  set props(Map data) {
    if (data != null) {
      _props = data;
    } else {
      _props = {};
    }
  }

  Map get props => _props;

  final bool svg;

  DomComponent({Map props, List<ComponentDescription> children, this.tagName,
      pair, this.svg: false})
      : this._props = props,
        this.pair = pair == null || pair,
        super(null, children) {
    if (_props != null &&
        !(_props is Map)) throw "Props should be map or string";
    if (_props == null) {
      _props = {};
    }
  }

  List<ComponentDescription> render() {
    return this.children;
  }
}

