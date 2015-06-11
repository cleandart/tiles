/**
 * Expected behavior:
 * Clicking repeatedly on the plus sign will switch back and forth between "collapsed" and "expanded" text.
 *
 * Actual behavior:
 * Clicking repeatedly on the plus sign will add the word "expanded"; or remove the word "expanded" and add the word "collapsed".
 * So after five clicks, you see "collapsedcollapsedcollapsed".
 * After six clicks, you see "collapsedcollapsedcollapsed <newline> expanded".
 */

import 'dart:html';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';

main() {
  initTilesBrowserConfiguration();
  var container = new DivElement();
  document.body.children.add(container);
  mountComponent(wordView(), container);
}

class WordView extends Component {
  bool expanded = true;
  WordView([props, children]) : super(props, children);

  render() {
    var toggleButton = div(
        props: {"id": "toggle"},
        listeners: {'onClick': toggle},
        children: ["+"]);
    if (expanded) {
      var lex = div(props: {"id": "expanded"}, children: ['expanded']);
      var lexArea = div(props: {"id": "expandedLex"}, children: [lex]);
      return div(children: [toggleButton, lexArea]);
    } else {
      var lex = div(props: {"id": "collapsed"}, children: ['collapsed']);
      return div(children: [toggleButton, lex]);
    }
  }

  toggle(a, b) {
    expanded = !expanded;
    redraw();
    return true;
  }
}

Component _wordViewCtor({var props, List<ComponentDescription> children}) =>
    new WordView(props, children);
var wordView = registerComponent(_wordViewCtor);
