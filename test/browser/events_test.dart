library tiles_browser_events_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
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

      component = new DomComponent(tagName: "span");

      description = new ComponentDescriptionMock();
      when(description.createComponent()).thenReturn(component);
    });

    test("shold return html element for correct component", () {
      mountComponent(description, mountRoot);

      expect(
          getElementForComponent(component), equals(mountRoot.children.first));
    });

    test("should controll type of event listener and throw if not correct", () {
      expect(
          () => mountComponent(span(listeners: {"onClick": () {}}), mountRoot),
          throws);
    });

    test("should accept correct event listener", () {
      expect(() => mountComponent(
          span(listeners: {"onClick": (Component component, Event event) {}}),
          mountRoot), isNot(throws));
    });

    test("should prevent default if component prevented default", () {
      mountComponent(span(listeners: {
        "onClick": expectAsync((Component component, Event event) {
          event.preventDefault();
        }, count: 1)
      }), mountRoot);

      mountRoot.on["click"].listen(expectAsync((Event event) {
        expect(event.defaultPrevented, isTrue);
      }));

      mountRoot.children.first.click();
    });

    test("should not prevent default if component not prevented default", () {
      mountComponent(
          span(listeners: {"onClick": (Component component, Event event) {}}),
          mountRoot);

      mountRoot.firstChild.on["click"].listen(expectAsync((Event event) {
        expect(event.defaultPrevented, isFalse);
      }));

      mountRoot.children.first.click();
    });

    test("should bubble event in correct order and only once", () {
      num order = 0;
      mountComponent(span(props: {"id": "wrapper",}, children: span(listeners: {
        "onClick": expectAsync((Component component, Event event) {
          expect(order++, equals(0));
        }, count: 1)
      }), listeners: {
        "onClick": expectAsync((Component component, Event event) {
          expect(order++, equals(1));
        }, count: 1)
      }), mountRoot);

      mountRoot.children.first.children.first.click();
    });

    test("should put correct component to event listeners", () {
      mountComponent(span(listeners: {
        "onClick": expectAsync((DomComponent component, Event event) {
          expect(component.tagName, equals("span"));
          expect(
              getElementForComponent(component), equals(mountRoot.firstChild));
        })
      }, children: div(listeners: {
        "onClick": expectAsync((DomComponent component, Event event) {
          expect(component.tagName, equals("div"));
          expect(getElementForComponent(component),
              equals(mountRoot.firstChild.firstChild));
        })
      })), mountRoot);

      mountRoot.children.first.children.first.click();
    });

    test("should ignore stopPropagation on event", () {
      mountComponent(span(
          listeners: {
        "onClick":
            expectAsync((DomComponent component, Event event) {}, count: 1)
      },
          children: div(listeners: {
        "onClick": expectAsync((DomComponent component, Event event) {
          event.stopPropagation();
        }, count: 1)
      })), mountRoot);

      mountRoot.children.first.children.first.click();
    });

    test("should not propagate up when listener returns false", () {
      mountComponent(span(
          listeners: {
        "onClick":
            expectAsync((DomComponent component, Event event) {}, count: 0)
      },
          children: div(listeners: {
        "onClick": expectAsync((DomComponent component, Event event) {
          return false;
        }, count: 1)
      })), mountRoot);

      mountRoot.children.first.children.first.click();
    });

    test(
        "should listen to events on custom component also, if props has [onEvent] in props",
        () {
      ComponentMock componentMock = new ComponentMock();
      when(componentMock.render()).thenReturn(div());
      ComponentDescriptionFactory component =
          registerComponent(({props, children}) => componentMock);

      mountComponent(component(
          listeners: {
        "onClick": expectAsync((Component component, Event event) {}, count: 1)
      }), mountRoot);

      mountRoot.children.first.click();
    });

    test("should accept custom event type", () {
      expect(() {
        mountComponent(div(
            listeners: {
          "onCustom": (Component component, Event event) => null
        }), mountRoot);
      }, isNot(throws));
    });

    test("should listen also to custom events", () {
      mountComponent(div(
          listeners: {
        "onCustomEvent": expectAsync((Component component, Event event) => null)
      }), mountRoot);
      mountRoot.children.first.dispatchEvent(new CustomEvent("customEvent"));
    });

    test("should listen accept event without 'on' prefix", () {
      mountComponent(div(
          listeners: {
        "customEvent": expectAsync((Component component, Event event) => null)
      }), mountRoot);
      mountRoot.children.first.dispatchEvent(new CustomEvent("customEvent"));
    });
  });
}
