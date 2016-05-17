library tiles_special_attributes_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';
import 'dart:async';
import 'package:tiles/src/dom/dom_attributes.dart';

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
      when(description.createComponent()).thenReturn(component);

      /**
       * prepare controller which simulates component redraw
       */
      controller = new StreamController();
      when(component.needUpdate).thenReturn(controller.stream);

      /**
       * prepare component mock redraw method
       * to work intuitively to easily writable test
       */
      when(component.shouldUpdate(any, any)).thenReturn(true);

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);
    });

    group("(value)", () {
      test("should set value if seted attribute value", () {
        when(component.render())
            .thenReturn(input(props: {value: value1}));

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.firstChild;
        expect(element.value, equals(value1));

        element.value = elseValue;

        controller.add(null);
        when(component.render())
            .thenReturn(input(props: {value: value2}));

        window.animationFrame.then(expectAsync((_) {
          expect(element.value, equals(value2));
        }));
      });

      test(
          "should set default value and not replace real value if seted attribute defaultValue",
          () {
        when(component.render())
            .thenReturn(input(props: {defaultValue: value1}))
            .thenReturn(input(props: {defaultValue: value2}));

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.firstChild;
        expect(element.value, equals(value1));

        element.value = elseValue;

        controller.add(null);

        window.animationFrame.then(expectAsync((_) {
          expect(element.value, equals(elseValue));
        }));
      });

      test('should add value into textarea from "value" prop', () {
        when(component.render())
            .thenReturn(textarea(props: {value: value1}, children: div()))
            .thenReturn(textarea(props: {value: value2}));

        mountComponent(description, mountRoot);

        TextAreaElement testareaEl = mountRoot.firstChild;
        expect(testareaEl.value, equals(value1));
      });

      test('should add value into textarea from "defaultValue" prop', () {
        when(component.render())
            .thenReturn(textarea(props: {defaultValue: value1}, children: div()))
            .thenReturn(textarea(props: {defaultValue: value2}));

        mountComponent(description, mountRoot);

        TextAreaElement testareaEl = mountRoot.firstChild;
        expect(testareaEl.value, equals(value1));
      });

      test('should update value in textarea from "value" prop', () {
        when(component.render())
            .thenReturn(textarea(props: {value: value1}, children: div()));

        mountComponent(description, mountRoot);

        TextAreaElement element = mountRoot.firstChild;
        expect(element.value, equals(value1));

        element.value = elseValue;

        controller.add(null);
        when(component.render())
            .thenReturn(textarea(props: {value: value2}));

        window.animationFrame.then(expectAsync((_) {
          expect(element.value, equals(value2));
        }));
      });
      test('should not update value into textarea from "defaultValue" prop', () {
        when(component.render())
            .thenReturn(textarea(props: {defaultValue: value1}, children: div()));

        mountComponent(description, mountRoot);

        TextAreaElement element = mountRoot.firstChild;
        expect(element.value, equals(value1));

        element.value = elseValue;

        controller.add(null);
        when(component.render())
            .thenReturn(textarea(props: {defaultValue: value2}));

        window.animationFrame.then(expectAsync((_) {
          expect(element.value, equals(elseValue));
        }));
      });
    });

    group("focus", () {
      test("should add focus to component with attribute focus: true", () {
        when(component.render())
            .thenReturn(input(props: {FOCUS: true}));

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.firstChild;
        expect(element, equals(window.document.activeElement));
      });

      test("should add focus to component with attribute focus: true after update", () {
        when(component.render())
            .thenReturn(input(props: {}));

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.firstChild;
        expect(element, isNot(equals(window.document.activeElement)));

        controller.add(null);
        when(component.render())
            .thenReturn(input(props: {FOCUS: true}));


        window.animationFrame.then(expectAsync((_) {
          expect(element, equals(window.document.activeElement));
        }));
      });

      test("should add focus to last component with attribute focus: true", () {
        when(component.render())
            .thenReturn([
          input(props: {FOCUS: true}),
          input(props: {FOCUS: true}),
          input(props: {FOCUS: true}),
        ]);

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.lastChild;
        expect(element, equals(window.document.activeElement));
      });

      test("should not add focus to component with attribute focus: false", () {
        when(component.render())
            .thenReturn(input(props: {FOCUS: false}));

        mountComponent(description, mountRoot);

        InputElement element = mountRoot.firstChild;
        expect(element, isNot(equals(window.document.activeElement)));
      });

    });


  });
}
