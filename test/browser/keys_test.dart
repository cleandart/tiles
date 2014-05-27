library tiles_browser_keys_test;

import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import 'dart:async';
import '../mocks.dart';

main() {
  group("(browser) (key)", () {
    Element mountRoot;
    ComponentMock component;
    ComponentDescriptionMock description;
    StreamController controller;
    List<String> keys = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    try {
      initTilesBrowserConfiguration();
    } catch (e) {}

    setUp(() {
      mountRoot = new DivElement();
      querySelector("body").append(mountRoot);

      component = new ComponentMock();

      description = new ComponentDescriptionMock();
      description.when(callsTo("createComponent"))
        .alwaysReturn(component);

      /**
       * prepare controller which simulates component redraw
       */
      controller = new StreamController();
      component.when(callsTo("get needUpdate"))
        .alwaysReturn(controller.stream);

      /**
       * prepare component mock redraw method
       * to work intuitively to easily writable test
       */
      component.when(callsTo("redraw"))
        .alwaysCall(([bool what]) => controller.add(what));
      component.when(callsTo("shouldUpdate")).alwaysReturn(true);
    });

    group("(simple move)", () {

      test("should just reorder elements, when all 2 child components have keys", () {
        component.when(callsTo("render"))
        .thenReturn(div(children: [
          span(key: "0"),
          span(key: "1"),
        ]))
        .thenReturn(div(children: [
          span(key: "1"),
          span(key: "0"),
        ]));

        mountComponent(description, mountRoot);

        expect(mountRoot.children.length, equals(1));
        expect(mountRoot.children.first.children.length, equals(2));
        Element divEl = mountRoot.children.first;
        Element first = divEl.children.first;
        Element second = divEl.children.last;

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.firstChild, equals(divEl));
          expect(divEl.firstChild, equals(second));
          expect(divEl.lastChild, equals(first));
        }));

      });

      test("should reorder longer list of children correctly", () {
        component.when(callsTo("render"))
        .thenReturn(div(children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 5}, key: "5"),
          span(props: {"id": 6}, key: "6"),
        ]))
        .thenReturn(div(children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 6}, key: "6"),
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 5}, key: "5"),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []
          ..addAll(divEl.children);

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.firstChild, equals(divEl));
          expect(divEl.children.length, equals(7));
          expect(divEl.children[0], equals(elements[0]));
          expect(divEl.children[1], equals(elements[3]));
          expect(divEl.children[2], equals(elements[2]));
          expect(divEl.children[3], equals(elements[4]));
          expect(divEl.children[4], equals(elements[6]));
          expect(divEl.children[5], equals(elements[1]));
          expect(divEl.children[6], equals(elements[5]));
        }));
      });

    test("should reorder longer list of children partial with keys correctly", () {
        component.when(callsTo("render"))
        .thenReturn(div(children: [
          span(),
          span(props: {"id": 1}, key: "1"),
          span(),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 5}, key: "5"),
          span(),
        ]))
        .thenReturn(div(children: [
                               span(),
          span(props: {"id": 3}, key: "3"),
          span(),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 6}, key: "5"),
          span(props: {"id": 1}, key: "1"),
          span(),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []
          ..addAll(divEl.children);

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.firstChild, equals(divEl));
          expect(divEl.children.length, equals(7));
          expect(divEl.children[0], equals(elements[0]));
          expect(divEl.children[1], equals(elements[3]));
          expect(divEl.children[2], equals(elements[2]));
          expect(divEl.children[3], equals(elements[4]));
          expect(divEl.children[4], equals(elements[5]));
          expect(divEl.children[5], equals(elements[1]));
          expect(divEl.children[6], equals(elements[6]));
        }));
      });

      test("should reorder correctly with new keys", () {
        component.when(callsTo("render"))
        .thenReturn(div(children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 1}, key: "1"),
          span(),
        ]))
        .thenReturn(div(children: [
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 0}, key: "0"),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []
          ..addAll(divEl.children);

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.firstChild, equals(divEl));
          expect(divEl.children.length, equals(3));
          expect(divEl.children[0], equals(elements[1]));
          expect(divEl.children[1], isNot(equals(elements[2])));
          expect(divEl.children[2], equals(elements[0]));
        }));
      });
    });

    group("(custom component move)", () {
      ComponentMock customComponent1;
      ComponentMock customComponent2;
      ComponentDescriptionMock customDescription1;
      ComponentDescriptionMock customDescription2;

      setUp(() {
        customComponent1 = new ComponentMock();
        customComponent2 = new ComponentMock();

        customDescription1 = new ComponentDescriptionMock();
        customDescription2 = new ComponentDescriptionMock();
        customDescription1.when(callsTo("createComponent"))
          .alwaysReturn(customComponent1);
        customDescription2.when(callsTo("createComponent"))
          .alwaysReturn(customComponent2);
        customDescription1.when(callsTo("get key")).alwaysReturn("key1");
        customDescription2.when(callsTo("get key")).alwaysReturn("key2");
        customComponent1.when(callsTo("shouldUpdate")).alwaysReturn(true);
        customComponent2.when(callsTo("shouldUpdate")).alwaysReturn(true);

      });

      test("should move child nodes of moved custom node", () {
        customDescription1 = new ComponentDescriptionMock();
        customDescription1.when(callsTo("createComponent")).alwaysReturn(customComponent1);
        customDescription1.when(callsTo("get key")).alwaysReturn("key");

        customComponent1.when(callsTo("render"))
          .thenReturn([div(), span()], 2);

        component.when(callsTo("render"))
          .thenReturn([
            img(key: "img"),
            input(key: "input"),
            customDescription1
          ])
          .thenReturn([
            img(key: "img"),
            customDescription1,
            input(key: "input"),
          ]);

        mountComponent(description, mountRoot);

        Element image  = mountRoot.children[0];
        Element inputt = mountRoot.children[1];
        Element divv   = mountRoot.children[2];
        Element spann  = mountRoot.children[3];

        expect(mountRoot.children.length, equals(4));
        expect(mountRoot.children[0] is ImageElement, isTrue);
        expect(mountRoot.children[1] is InputElement, isTrue);
        expect(mountRoot.children[2] is DivElement, isTrue);
        expect(mountRoot.children[3] is SpanElement, isTrue);

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children.length, equals(4));
          expect(mountRoot.children[0], equals(image));
          expect(mountRoot.children[1], equals(divv));
          expect(mountRoot.children[2], equals(spann));
          expect(mountRoot.children[3] is InputElement, isTrue);
        }));
      });
      test("should move child nodes of moved custom component and inside of the component", () {
        customComponent1.when(callsTo("render"))
          .thenReturn([span(key: "SPAN"), div(key: "DIV"), ])
        .thenReturn([div(key: "DIV"), span(key: "SPAN"), ]);

        component.when(callsTo("render"))
          .thenReturn([img(), input(), customDescription1])
          .thenReturn([img(), customDescription1, input()]);

        mountComponent(description, mountRoot);

        Element spann  = mountRoot.children[2];
        Element divv   = mountRoot.children[3];

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children[1], equals(divv));
          expect(mountRoot.children[2], equals(spann));
        }));
      });

      test("should move more than one custom components correctly", () {
        customComponent1.when(callsTo("render"))
          .alwaysReturn([span(), div()]);

        customComponent2.when(callsTo("render"))
          .alwaysReturn([span(), div()]);

        component.when(callsTo("render"))
          .thenReturn([customDescription1, customDescription2])
          .thenReturn([customDescription2, customDescription1]);

        mountComponent(description, mountRoot);

        Element span1  = mountRoot.children[0];
        Element div1   = mountRoot.children[1];
        Element span2  = mountRoot.children[2];
        Element div2   = mountRoot.children[3];

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children[0], equals(span2));
          expect(mountRoot.children[1], equals(div2));
          expect(mountRoot.children[2], equals(span1));
          expect(mountRoot.children[3], equals(div1));
        }));

      });

      test("should move more than one custom components correctly with move of insde components", () {
        customComponent1.when(callsTo("render"))
          .thenReturn([
            span(key: "span1"),
            div(key: "div1"),
          ])
          .thenReturn([
            div(key: "div1"),
            span(key: "span1"),
          ]);

        customComponent2.when(callsTo("render"))
          .alwaysReturn([span(), div()]);


        component.when(callsTo("render"))
          .thenReturn([customDescription1, customDescription2])
          .thenReturn([customDescription2, customDescription1]);

        mountComponent(description, mountRoot);

        Element span1  = mountRoot.children[0];
        Element div1   = mountRoot.children[1];
        Element span2  = mountRoot.children[2];
        Element div2   = mountRoot.children[3];

        component.redraw();

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children[0], equals(span2));
          expect(mountRoot.children[1], equals(div2));
          expect(mountRoot.children[2], equals(div1));
          expect(mountRoot.children[3], equals(span1));
        }));

      });
    });
  });
}
