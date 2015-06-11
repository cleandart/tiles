library tiles_special_attributes_test;

import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';
import 'dart:async';

main() {
  group("(browser) (Special HTML Sttributes)", () {
    Element mountRoot;
    const String value = "value";
    const String value1 = "value1";
    const String value2 = "value2";
    const String elseValue = "something else";
    const String defaultValue = "defaultValue";

    ComponentMock component;
    ComponentDescriptionMock description;
    StreamController controller;

    try {
      initTilesBrowserConfiguration();
    } catch (e) {}

    setUp(() {
      /**
       * create new mountRoot
       */
      mountRoot = new Element.div();

      /**
       * Prepare mock component and description
       */

      component = new ComponentMock();

      description = new ComponentDescriptionMock();
      description.when(callsTo("createComponent")).alwaysReturn(component);

      /**
       * prepare controller which simulates component redraw
       */
      controller = new StreamController();
      component.when(callsTo("get needUpdate")).alwaysReturn(controller.stream);

      /**
       * prepare component mock redraw method
       * to work intuitively to easily writable test
       */
      component
          .when(callsTo("redraw"))
          .alwaysCall(([bool what]) => controller.add(what));
      component.when(callsTo("shouldUpdate")).alwaysReturn(true);

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);
    });

    test("should set value if seted attribute value", () {
      component
          .when(callsTo("render"))
          .thenReturn(input(props: {value: value1}))
          .thenReturn(input(props: {value: value2}));

      mountComponent(description, mountRoot);

      InputElement element = mountRoot.firstChild;
      expect(element.value, equals(value1));

      element.value = elseValue;

      component.redraw();

      window.animationFrame.then(expectAsync((_) {
        expect(element.value, equals(value2));
      }));
    });

    test(
        "should set default value and not replace real value if seted attribute defaultValue",
        () {
      component
          .when(callsTo("render"))
          .thenReturn(input(props: {defaultValue: value1}))
          .thenReturn(input(props: {defaultValue: value2}));

      mountComponent(description, mountRoot);

      InputElement element = mountRoot.firstChild;
      expect(element.value, equals(value1));

      element.value = elseValue;

      component.redraw();

      window.animationFrame.then(expectAsync((_) {
        expect(element.value, equals(elseValue));
      }));
    });

    test('should add value into textarea from "value" prop', () {
      component
          .when(callsTo("render"))
          .thenReturn(textarea(props: {value: value1}, children: div()))
          .thenReturn(textarea(props: {value: value2}));

      mountComponent(description, mountRoot);

      TextAreaElement testareaEl = mountRoot.firstChild;
      expect(testareaEl.value, equals(value1));
    });

    test('should update value in textarea from "value" prop', () {
      component
          .when(callsTo("render"))
          .thenReturn(textarea(props: {value: value1}, children: div()))
          .thenReturn(textarea(props: {value: value2}));

      mountComponent(description, mountRoot);

      TextAreaElement element = mountRoot.firstChild;
      expect(element.value, equals(value1));

      element.value = elseValue;

      component.redraw();

      window.animationFrame.then(expectAsync((_) {
        expect(element.value, equals(value2));
      }));
    });
  });
}
