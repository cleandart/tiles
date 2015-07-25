library tiles_string;

import 'tiles.dart';
import 'src/dom/dom_attributes.dart';

String renderToString(ComponentDescription source) {
  Component component = source.createComponent();
  if (component is DomComponent) {
    return _renderDomComponent(component);
  }
  if (component is DomTextComponent) {
    return component.props;
  }
  if (component is Component) {
    return _renderComponent(component);
  }
}

String _renderComponent(Component component) {
  return _children(component.render());
}

String _renderDomComponent(DomComponent component) {
  StringBuffer buffer = new StringBuffer(_tagStart(component.tagName) +
      _renderProps(component) +
      _tagEnd(component.pair));
  if (component.pair) {
    if (component is TextareaComponent) {
      buffer.write(_getValue(component.props));
    }
    buffer.write(_children(component.children));
    buffer.write(_endTag(component.tagName));
  }
  return buffer.toString();
}

Object _getValue(Map props) {
  if (props.containsKey(VALUE)) {
    return props[VALUE];
  } else if (props.containsKey(DEFAULTVALUE)) {
    return props[DEFAULTVALUE];
  } else {
    return "";
  }
}

Object _children(dynamic children) {
  if (children is ComponentDescription) {
    return renderToString(children);
  }
  if (children is List<ComponentDescription>) {
    return children.map((child) => renderToString(child)).join();
  }
  return "";
}

String _endTag(String tagName) {
  return "</$tagName>";
}

_tagEnd(bool pair) {
  if (pair) {
    return ">";
  }
  return " />";
}

_tagStart(String tag) {
  return "<$tag";
}

_renderProps(DomComponent component) {
  if (component.props == null || component.props.isEmpty) {
    return "";
  }
  return component.props.keys
      .map((String key) => _renderAttribute(key, component))
      .join();
}

_renderAttribute(String key, DomComponent component) {
  if (canAddAttribute(component.svg, key) &&
      _shouldRenderAttribute(key, component)) {
    return ' ${_normalizeAttribute(key)}="${component.props[key]}"';
  }
  return "";
}

_normalizeAttribute(String key) {
  return key.replaceAll(new RegExp(DEFAULTVALUE), VALUE);
}

bool _shouldRenderAttribute(String key, DomComponent component) {
  return isNotValue(key) || !_shouldNotRenderValue(component, key);
}

bool _shouldNotRenderValue(DomComponent component, String key) =>
    ((component is TextareaComponent) ||
        (key == DEFAULTVALUE && component.props.keys.contains(VALUE)));

bool isNotValue(String key) => (key != VALUE && key != DEFAULTVALUE);
