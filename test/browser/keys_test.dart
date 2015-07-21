library tiles_browser_keys_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
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
    });

    group("(simple move)", () {
      test(
          "should just reorder elements, when all 2 child components have keys",
          () {
        when(component.render())
            .thenReturn(div(children: [span(key: "0"), span(key: "1"),]));

        mountComponent(description, mountRoot);

        expect(mountRoot.children.length, equals(1));
        expect(mountRoot.children.first.children.length, equals(2));
        Element divEl = mountRoot.children.first;
        Element first = divEl.children.first;
        Element second = divEl.children.last;

        controller.add(null);
        when(component.render())
            .thenReturn(div(children: [span(key: "1"), span(key: "0"),]));

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.firstChild, equals(divEl));
          expect(divEl.firstChild, equals(second));
          expect(divEl.lastChild, equals(first));
        }));
      });

      test("should reorder longer list of children correctly", () {
        when(component.render()).thenReturn(div(
            children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 5}, key: "5"),
          span(props: {"id": 6}, key: "6"),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []..addAll(divEl.children);

        controller.add(null);
        when(component.render()).thenReturn(div(
            children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 6}, key: "6"),
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 5}, key: "5"),
        ]));

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

      test("should reorder longer list of children partial with keys correctly",
          () {
        when(component.render()).thenReturn(div(
            children: [
          span(),
          span(props: {"id": 1}, key: "1"),
          span(),
          span(props: {"id": 3}, key: "3"),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 5}, key: "5"),
          span(),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []..addAll(divEl.children);

        controller.add(null);
        when(component.render()).thenReturn(div(
            children: [
          span(),
          span(props: {"id": 3}, key: "3"),
          span(),
          span(props: {"id": 4}, key: "4"),
          span(props: {"id": 6}, key: "5"),
          span(props: {"id": 1}, key: "1"),
          span(),
        ]));

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
        when(component.render()).thenReturn(div(
            children: [
          span(props: {"id": 0}, key: "0"),
          span(props: {"id": 1}, key: "1"),
          span(),
        ]));

        mountComponent(description, mountRoot);

        Element divEl = mountRoot.firstChild;

        List<Element> elements = []..addAll(divEl.children);

        controller.add(null);
        when(component.render()).thenReturn(div(
            children: [
          span(props: {"id": 1}, key: "1"),
          span(props: {"id": 2}, key: "2"),
          span(props: {"id": 0}, key: "0"),
        ]));

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
        when(customDescription1.createComponent()).thenReturn(customComponent1);
        when(customDescription2.createComponent()).thenReturn(customComponent2);
        when(customDescription1.key).thenReturn("key1");
        when(customDescription2.key).thenReturn("key2");
        when(customComponent1.shouldUpdate(any, any)).thenReturn(true);
        when(customComponent2.shouldUpdate(any, any)).thenReturn(true);
      });

      test("should move child nodes of moved custom node", () {
        customDescription1 = new ComponentDescriptionMock();
        when(customDescription1.createComponent()).thenReturn(customComponent1);
        when(customDescription1.key).thenReturn("key");

        when(customComponent1.render()).thenReturn([div(), span()]);

        when(component.render()).thenReturn(
            [img(key: "img"), input(key: "input"), customDescription1]);

        mountComponent(description, mountRoot);

        Element image = mountRoot.children[0];
        Element inputt = mountRoot.children[1];
        Element divv = mountRoot.children[2];
        Element spann = mountRoot.children[3];

        expect(mountRoot.children.length, equals(4));
        expect(mountRoot.children[0] is ImageElement, isTrue);
        expect(mountRoot.children[1] is InputElement, isTrue);
        expect(mountRoot.children[2] is DivElement, isTrue);
        expect(mountRoot.children[3] is SpanElement, isTrue);

        controller.add(null);
        when(component.render()).thenReturn(
            [img(key: "img"), customDescription1, input(key: "input"),]);

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children.length, equals(4));
          expect(mountRoot.children[0], equals(image));
          expect(mountRoot.children[1], equals(divv));
          expect(mountRoot.children[2], equals(spann));
          expect(mountRoot.children[3] is InputElement, isTrue);
        }));
      });
      test(
          "should move child nodes of moved custom component and inside of the component",
          () {
        when(customComponent1.render())
            .thenReturn([span(key: "SPAN"), div(key: "DIV"),]);

        when(component.render())
            .thenReturn([img(), input(), customDescription1]);

        mountComponent(description, mountRoot);

        Element spann = mountRoot.children[2];
        Element divv = mountRoot.children[3];

        controller.add(null);
        when(customComponent1.render())
            .thenReturn([div(key: "DIV"), span(key: "SPAN"),]);
        when(component.render())
            .thenReturn([img(), customDescription1, input()]);

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children[1], equals(divv));
          expect(mountRoot.children[2], equals(spann));
        }));
      });

      test("should move more than one custom components correctly", () {
        when(customComponent1.render()).thenReturn([span(), div()]);

        when(customComponent2.render()).thenReturn([span(), div()]);

        when(component.render())
            .thenReturn([customDescription1, customDescription2]);

        mountComponent(description, mountRoot);

        Element span1 = mountRoot.children[0];
        Element div1 = mountRoot.children[1];
        Element span2 = mountRoot.children[2];
        Element div2 = mountRoot.children[3];

        controller.add(null);
        when(component.render())
            .thenReturn([customDescription2, customDescription1]);

        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children[0], equals(span2));
          expect(mountRoot.children[1], equals(div2));
          expect(mountRoot.children[2], equals(span1));
          expect(mountRoot.children[3], equals(div1));
        }));
      });

      test(
          "should move more than one custom components correctly with move of insde components",
          () {
        when(customComponent1.render())
            .thenReturn([span(key: "span1"), div(key: "div1"),]);

        when(customComponent2.render()).thenReturn([span(), div()]);

        when(component.render())
            .thenReturn([customDescription1, customDescription2]);

        mountComponent(description, mountRoot);

        Element span1 = mountRoot.children[0];
        Element div1 = mountRoot.children[1];
        Element span2 = mountRoot.children[2];
        Element div2 = mountRoot.children[3];

        controller.add(null);
        when(customComponent1.render())
            .thenReturn([div(key: "div1"), span(key: "span1"),]);
        when(component.render())
            .thenReturn([customDescription2, customDescription1]);

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
