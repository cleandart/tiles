library tiles_update_component_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';
import 'dart:async';

main() {
  group("(browser) (updateComponent)", () {
    Element mountRoot;

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

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);
    });

    test("should rerender after component called redraw", () {
      component.when(callsTo("render"))
        .thenReturn([span()])
        .thenReturn([img()]);

      mountComponent(description, mountRoot);

      component.redraw();

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.length, equals(1));
        expect(mountRoot.children.first is ImageElement, isTrue);
      }));
    });

    test("should replace only inner element, which should be replaced", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(children: span()), div()];
        })
        .thenCall(() {
          return [div(children: img()), div()];
        });

      mountComponent(description, mountRoot);


      expect(mountRoot.children.first.children.length, equals(1));
      expect(mountRoot.children.first.children.first is SpanElement, isTrue, reason: "div should contain span");

      var dd = mountRoot.childNodes.first;

      component.redraw();

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.length, equals(2));
        expect(mountRoot.children.first, equals(dd));
        expect(mountRoot.children.first.children.length, equals(1));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });

    test("should replace element at place", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(children: [span(), span()])];
        })
        .thenCall(() {
          return [div(children: [img(), span()])];
        });

      mountComponent(description, mountRoot);

      component.redraw();

      Element sp = mountRoot.children.first.children.last;

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });

    test("should replace 2 elements at place", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(children: [span(), span(), span()])];
        })
        .thenCall(() {
          return [div(children: [div(), img(), span()])];
        });

      mountComponent(description, mountRoot);

      component.redraw();

      Element sp = mountRoot.children.first.children.last;

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children[0] is DivElement, isTrue, reason: "span should be replaced by image");
        expect(mountRoot.children.first.children[1]is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });

    test("should replace elements properly in more complicated example", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(children: [
                    span(),
                    span(),
                    span(children: div(children: [
                        span(),
                        div(),
                        img(),
                        a()
                      ])),
                    span()
                 ])];
        })
        .thenCall(() {
          return [div(children: [
                    div(),
                    img(),
                    span(children: div(children: [
                        span(),
                        i(),
                        img(),
                        b()
                      ])),
                    form()
                ])];
        });

      mountComponent(description, mountRoot);

      component.redraw();

      Element sp = mountRoot.children.first.children[2];

      Element innerSpan = sp.children.first.children[0];
      Element innerImage = sp.children.first.children[2];

      window.animationFrame.then(expectAsync((something) {
        var children = mountRoot.children.first.children;
        expect(children[0] is DivElement, isTrue, reason: "span should be replaced by image");
        expect(children[1] is ImageElement, isTrue, reason: "span should be replaced by image");
        expect(children[2], equals(sp));
        expect(children[3] is FormElement, isTrue);

        List<Element> innerChildren = children[2].children.first.children;

        expect(innerChildren[0], equals(innerSpan));
        expect(innerChildren[1].tagName.toLowerCase() , equals("i"));
        expect(innerChildren[2], equals(innerImage));
        expect(innerChildren[3].tagName.toLowerCase() , equals("b"));
      }));
    });

    test("should update attrs of element to exact match with that which is contained in component", () {
      String myClass = "myclass",
          myOtherClass = "myotherclass",
          id = "myId";
      int height = 12;

      component.when(callsTo("render"))
        .thenReturn([span(props: {"class": myClass, "id": id})])
        .thenReturn([span(props: {"class": myOtherClass, "height": height})]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.getAttribute("class"), equals(myClass));
      expect(mountRoot.children.first.getAttribute("id"), equals(id));
      expect(mountRoot.children.first.attributes.containsKey("height"), isFalse, reason: "should not contain height");
      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"), equals(myOtherClass), reason: "class should change");
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse, reason: "id should be removed");
        expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");
      }));
    });

    test("should filter added attributes on update", () {
      /**
       * one html attribute, one svg and one non of them
       */
      component.when(callsTo("render"))
        .thenReturn([span(props: {})])
        .thenReturn([span(props: {"class": "class", "text": "text", "crap": "crap"})]);

      mountComponent(description, mountRoot);

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("class"), isTrue);
        expect(mountRoot.children.first.attributes.containsKey("text"), isFalse);
      }));
    });

    test("should filter changed attributes on update", () {
      /**
       * one html attribute, one svg and one non of them
       */
      component.when(callsTo("render"))
        .thenReturn([span(props: {"id": "id", "d": "d", "crap": "crap"})])
        .thenReturn([span(props: {"id": "id2", "d": "d2", "crap": "crap2"})]);

      mountComponent(description, mountRoot);

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isTrue);
        expect(mountRoot.children.first.attributes.containsKey("d"), isFalse);
      }));
    });

    test("should filter added attributes on update in svg component", () {
      /**
       * one html attribute, one svg and one non of them
       */
      component.when(callsTo("render"))
        .thenReturn([svg(props: {})])
        .thenReturn([svg(props: {"id": "id2", "d": "d2", "crap": "crap"})]);

      mountComponent(description, mountRoot);

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      }));
    });

    test("should filter changed attributes on update in svg component", () {
      /**
       * one html attribute, one svg and one non of them
       */
      component.when(callsTo("render"))
        .thenReturn([svg(props: {"id": "id", "d": "d", "crap": "crap"})])
        .thenReturn([svg(props: {"id": "id2", "d": "d2", "crap": "crap2"})]);

      mountComponent(description, mountRoot);

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      }));
    });

    test("should add props if prev props was null", () {
      String myClass = "myclass";
      int height = 12;

      component.when(callsTo("render"))
        .thenReturn([span()])
        .thenReturn([span(props: {"class": myClass, "height": height})]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.attributes, isEmpty);

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"), equals(myClass), reason: "class should change");
        expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");
      }));
    });

    test("should remove props if prev props was contains some attributes", () {
      String myClass = "myclass";
      int height = 12;

      component.when(callsTo("render"))
        .thenReturn([span(props: {"class": myClass, "height": height})])
        .thenReturn([span()]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.getAttribute("class"), equals(myClass), reason: "class should change");
      expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes, isEmpty);
      }));
    });

    test("should remove all children of removed not dom component", () {
      ComponentMock componentWithSpan = new ComponentMock();
      componentWithSpan.when(callsTo("render")).alwaysReturn([span()]);

      componentWithSpan.when(callsTo("shouldUpdate")).alwaysReturn(true);

      ComponentDescriptionMock descriptionWithSpan = new ComponentDescriptionMock();
      descriptionWithSpan.when(callsTo("createComponent")).alwaysReturn(componentWithSpan);

      component.when(callsTo("render"))
        .thenReturn([descriptionWithSpan])
        .thenReturn([]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(0));

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.length, equals(0));
      }));
    });

    ComponentDescriptionMock prepareTestCase() {
      /*
       * Imagine following structure:
       *
       * Cmp1: [Cmp2: [div1, div2], Cmp3: [div3, div4]]
       *
       * Now, Cmp1, Cmp2, Cmp3 all have the same mountRoot.
       *
       * However, we need to ensure, that div3 is inserted after div2. What if Cmp2 is updated, Cmp3 is not and div2 ends after div4?
       */
      ComponentMock cmp1 = new ComponentMock();
      cmp1.when(callsTo("get needUpdate"))
        .alwaysReturn(controller.stream);
      cmp1.when(callsTo("redraw"))
        .alwaysCall(([bool what]) => controller.add(what));
      cmp1.when(callsTo("shouldUpdate")).alwaysReturn(true);


      ComponentDescriptionMock desc1 = new ComponentDescriptionMock();
      desc1.when(callsTo("createComponent")).alwaysReturn(cmp1);


      ComponentMock cmp2 = new ComponentMock();
      cmp2.when(callsTo("shouldUpdate")).alwaysReturn(true);
      ComponentDescriptionMock desc2 = new ComponentDescriptionMock();
      desc2.when(callsTo("createComponent")).alwaysReturn(cmp2);

      ComponentMock cmp3 = new ComponentMock();
      cmp3.when(callsTo("shouldUpdate")).alwaysReturn(true);
      ComponentDescriptionMock desc3 = new ComponentDescriptionMock();
      desc3.when(callsTo("createComponent")).alwaysReturn(cmp3);

      cmp1.when(callsTo("render")).alwaysReturn([desc2, desc3]);
      cmp2.when(callsTo("render"))
        .thenReturn([div(props: {"id": "div1"}), div(props: {"id": "div2"})])  /*div1, div2*/
        .thenReturn([div(props: {"id": "div1"}), div(props: {"id": "div2"})])
        .thenReturn([div(props: {"id": "div1"}), div(props: {"id": "div2"})])
        .thenReturn([div(props: {"id": "div1"}), span()]); // replace div2 by span
      cmp3.when(callsTo("render"))
        .thenReturn([div(props: {"id": "div3"}), div(props: {"id": "div4"})])
        .thenReturn([div(props: {"id": "div3.1"}), div(props: {"id": "div4"})])
        .thenReturn([span(), div()])
        .thenReturn([span(), div()]);

      return desc1;
    }

    test("should only update div attributes when all children are stil div", () {
      description = prepareTestCase();
      mountComponent(description, mountRoot);

      expect(mountRoot.children.length, equals(4));
      Element div1 = mountRoot.children[0];
      Element div2 = mountRoot.children[1];
      Element div3 = mountRoot.children[2];
      Element div4 = mountRoot.children[3];

      expect(div3.attributes['id'], equals("div3"));

      /**
       * update just id of div3 after first update
       */
      description.createComponent().redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.length, equals(4));

        expect(mountRoot.children[0], equals(div1));
        expect(mountRoot.children[1], equals(div2));
        expect(mountRoot.children[2], equals(div3));
        expect(mountRoot.children[3], equals(div4));

        expect(div3.attributes['id'], equals("div3.1"));
      }));
    });

    test("should place elements correctly when div3 changed to span", () {
      description = prepareTestCase();
      mountComponent(description, mountRoot);

      expect(mountRoot.children.length, equals(4));
      Element div1 = mountRoot.children[0];
      Element div2 = mountRoot.children[1];
      Element div3 = mountRoot.children[2];
      Element div4 = mountRoot.children[3];

      expect(div3.attributes['id'], equals("div3"));

      /**
       * update twice to replace div3 by span
       */
      description.createComponent().redraw();

      window.animationFrame.then(expectAsync((data) {
        description.createComponent().redraw();

        window.animationFrame.then(expectAsync((data) {
          expect(mountRoot.children.length, equals(4));

          expect(mountRoot.children[0], equals(div1));
          expect(mountRoot.children[1], equals(div2));
          expect(mountRoot.children[2], isNot(equals(div3)));
          expect(mountRoot.children[2] is SpanElement, isTrue);
          expect(mountRoot.children[2].attributes["id"], isNull);
          expect(mountRoot.children[3], equals(div4));

        }));
      }));
    });

    test("should place elements correctly when div2 changed to span", () {
      description = prepareTestCase();
      mountComponent(description, mountRoot);

      expect(mountRoot.children.length, equals(4));
      Element div1 = mountRoot.children[0];
      Element div2 = mountRoot.children[1];
      Element div3 = mountRoot.children[2];
      Element div4 = mountRoot.children[3];

      expect(div3.attributes['id'], equals("div3"));

      /**
       * update twice to replace div3 by span
       */
      description.createComponent().redraw();
      window.animationFrame.then(expectAsync((data) {
        description.createComponent().redraw();

        window.animationFrame.then(expectAsync((data) {
          description.createComponent().redraw();

          window.animationFrame.then(expectAsync((data) {
            expect(mountRoot.children.length, equals(4));

            expect(mountRoot.children[0], equals(div1));
            expect(mountRoot.children[1], isNot(equals(div2)));
            expect(mountRoot.children[1] is SpanElement, isTrue);
            expect(mountRoot.children[2], isNot(equals(div3)));
            expect(mountRoot.children[2] is SpanElement, isTrue);
            expect(mountRoot.children[3], equals(div4));
          }));
        }));
      }));
    });

    test("should remove relations between component(node) and element", () {
      Component spanComponent = span().createComponent();
      ComponentDescriptionMock spanDescription = new ComponentDescriptionMock();
      spanDescription.when(callsTo("createComponent")).alwaysReturn(spanComponent);

      component.when(callsTo("render"))
        .thenReturn([spanDescription])
        .thenReturn([]);

      mountComponent(description, mountRoot);

      expect(mountRoot.firstChild is SpanElement, isTrue);
      expect(getElementForComponent(spanComponent), equals(mountRoot.firstChild));

      Element spanElement = mountRoot.firstChild;

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.firstChild, isNull, reason: "mountRoot should be empty");
        expect(getElementForComponent(spanComponent), isNull, reason: "dependence should be removed");
      }));

    });

    test("should change text inside of html when update of text component ", () {
      String text1 = "hello",
          text2 = "aloha";
      component.when(callsTo("render"))
        .thenReturn(div(children: text1))
        .thenReturn(div(children: text2));

      mountComponent(description, mountRoot);

      Text text = mountRoot.firstChild.firstChild;
      expect(text is Text, isTrue);
      expect(text.text, equals(text1));

      component.redraw();

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.firstChild.firstChild, equals(text));
        expect(text.text, equals(text2));
      }));
    });

  });
}

