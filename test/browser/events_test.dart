library tiles_browser_events_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';

main() {
  group("(browser) (events)", () {
    Element mountRoot;
    ComponentDescriptionMock description;
    Component component;

    setUp(() {
      mountRoot = new Element.div();
      /**
       * we need to add this element to DOM to test bubbling of events
       */
      querySelector("body").append(mountRoot);

      component = new DomComponent(null, null, "span");

      description = new ComponentDescriptionMock();
      description.when(callsTo("createComponent")).alwaysReturn(component);
    });

    test("shold return html element for correct component", () {
      mountComponent(description, mountRoot);

      expect(getElementForComponent(component), equals(mountRoot.children.first));

    });

    test("should controll type of event listener and throw if not correct", () {
      expect(() => mountComponent(span({"onClick": () {} }), mountRoot), throws);
    });

    test("should accept correct event listener", () {
      expect(() => mountComponent(span({"onClick": (Component component, Event event) {} }), mountRoot), isNot(throws));
    });

    test("should prevent default if component prevented default", () {
      mountComponent(span({
        "onClick": (Component component, Event event) {
          event.preventDefault();
        }
      }), mountRoot);

      mountRoot.on["click"].listen(expectAsync((Event event) {
        expect(event.defaultPrevented, isTrue);
      }));

      mountRoot.children.first.click();

    });

    test("should not prevent default if component not prevented default", () {
      mountComponent(span({
        "onClick": (Component component, Event event) {}
      }), mountRoot);

      mountRoot.firstChild.on["click"].listen(expectAsync((Event event) {
        expect(event.defaultPrevented, isFalse);
      }));

      mountRoot.children.first.click();

    });

    test("should bubble event in correct order and only once", () {
      num order = 0;
      mountComponent(span({
        "id": "wrapper",
        "onClick": expectAsync((Component component, Event event) {
          expect(order++, equals(1));
        }, count: 1)
      }, span({
        "onClick": expectAsync((Component component, Event event) {
          expect(order++, equals(0));
        }, count: 1)
      })), mountRoot);

      mountRoot.children.first.children.first.click();

    });

    test("should put correct component to event listeners", () {
      mountComponent(span({
        "onClick": expectAsync((DomComponent component, Event event) {
          expect(component.tagName, equals("span"));
          expect(getElementForComponent(component), equals(mountRoot.firstChild));
        })
      }, div({
        "onClick": expectAsync((DomComponent component, Event event) {
          expect(component.tagName, equals("div"));
          expect(getElementForComponent(component), equals(mountRoot.firstChild.firstChild));
        })
      })), mountRoot);

      mountRoot.children.first.children.first.click();
    });

    test("should ignore stopPropagation on event", () {
      mountComponent(span({
        "onClick": expectAsync((DomComponent component, Event event) {
        }, count: 1)
      }, div({
        "onClick": expectAsync((DomComponent component, Event event) {
          event.stopPropagation();
        }, count: 1)
      })), mountRoot);

      mountRoot.children.first.children.first.click();
    });

  });
}
