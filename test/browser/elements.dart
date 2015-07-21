library tiles_browser_elements_test;

import 'package:test/test.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';

main() {
  group("(browser) (elements)", () {
    Element mountRoot;

    setUp(() {
      mountRoot = new Element.div();
      /**
       * we need to add this element to DOM to test bubbling of events
       */
      querySelector("body").append(mountRoot);

    });

    test('shold add "cols" and "rows" to textarea', () {
      mountComponent(textarea(props: {"cols": 3, "rows": 5}), mountRoot);

      TextAreaElement textareaEl = mountRoot.firstChild;

      expect(mountRoot.firstChild is TextAreaElement, isTrue);
      expect(textareaEl.cols, equals(3));
      expect(textareaEl.rows, equals(5));

    });

  });
}
