library tiles_update_component_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';
import 'dart:async';
import 'package:tiles/src/dom/dom_attributes.dart';

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
      when(component.shouldUpdate).thenReturn(true);

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);
    });

    test("should rerender after component called redraw", () {
      when(component.render()).thenReturn([span()]);

      mountComponent(description, mountRoot);

      when(component.render()).thenReturn([img()]);
      controller.add(true);

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.length, equals(1));
        expect(mountRoot.children.first is ImageElement, isTrue);
      }));
    });

    test("should replace only inner element, which should be replaced", () {
      when(component.render()).thenReturn([div(children: span()), div()]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.children.length, equals(1));
      expect(mountRoot.children.first.children.first is SpanElement, isTrue,
          reason: "div should contain span");

      var dd = mountRoot.childNodes.first;

      when(component.render()).thenReturn([div(children: img()), div()]);
      controller.add(true);

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.length, equals(2));
        expect(mountRoot.children.first, equals(dd));
        expect(mountRoot.children.first.children.length, equals(1));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue,
            reason: "span should be replaced by image");
      }));
    });

    test("should replace element at place", () {
      when(component.render()).thenReturn([div(children: [span(), span()])]);

      mountComponent(description, mountRoot);

      when(component.render()).thenReturn([div(children: [img(), span()])]);
      controller.add(true);

      Element sp = mountRoot.children.first.children.last;

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue,
            reason: "span should be replaced by image");
      }));
    });

    test("should replace 2 elements at place", () {
      when(component.render())
          .thenReturn([div(children: [span(), span(), span()])]);

      mountComponent(description, mountRoot);

      when(component.render())
          .thenReturn([div(children: [div(), img(), span()])]);
      controller.add(true);

      Element sp = mountRoot.children.first.children.last;

      window.animationFrame.then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children[0] is DivElement, isTrue,
            reason: "span should be replaced by image");
        expect(mountRoot.children.first.children[1] is ImageElement, isTrue,
            reason: "span should be replaced by image");
      }));
    });

    test("should replace elements properly in more complicated example", () {
      when(component.render()).thenReturn([
        div(
            children: [
          span(),
          span(),
          span(children: div(children: [span(), div(), img(), a()])),
          span()
        ])
      ]);

      mountComponent(description, mountRoot);

      when(component.render()).thenReturn([
        div(
            children: [
          div(),
          img(),
          span(children: div(children: [span(), i(), img(), b()])),
          form()
        ])
      ]);
      controller.add(true);

      Element sp = mountRoot.children.first.children[2];

      Element innerSpan = sp.children.first.children[0];
      Element innerImage = sp.children.first.children[2];

      window.animationFrame.then(expectAsync((something) {
        var children = mountRoot.children.first.children;
        expect(children[0] is DivElement, isTrue,
            reason: "span should be replaced by image");
        expect(children[1] is ImageElement, isTrue,
            reason: "span should be replaced by image");
        expect(children[2], equals(sp));
        expect(children[3] is FormElement, isTrue);

        List<Element> innerChildren = children[2].children.first.children;

        expect(innerChildren[0], equals(innerSpan));
        expect(innerChildren[1].tagName.toLowerCase(), equals("i"));
        expect(innerChildren[2], equals(innerImage));
        expect(innerChildren[3].tagName.toLowerCase(), equals("b"));
      }));
    });

    test(
        "should update attrs of element to exact match with that which is contained in component",
        () {
      String myClass = "myclass",
          myOtherClass = "myotherclass",
          id = "myId";
      int height = 12;

      when(component.render())
          .thenReturn([span(props: {"class": myClass, "id": id})]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.getAttribute("class"), equals(myClass));
      expect(mountRoot.children.first.getAttribute("id"), equals(id));
      expect(mountRoot.children.first.attributes.containsKey("height"), isFalse,
          reason: "should not contain height");
      controller.add(true);
      when(component.render())
          .thenReturn([span(props: {"class": myOtherClass, "height": height})]);

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"),
            equals(myOtherClass), reason: "class should change");
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse,
            reason: "id should be removed");
        expect(mountRoot.children.first.getAttribute("height"),
            equals(height.toString()), reason: "haight should be added");
      }));
    });

    test("should filter added attributes on update", () {
      /**
       * one html attribute, one svg and one non of them
       */
      when(component.render()).thenReturn([span(props: {})]);

      mountComponent(description, mountRoot);

      controller.add(true);
      when(component.render()).thenReturn(
          [span(props: {"class": "class", "text": "text", "crap": "crap"})]);

      window.animationFrame.then(expectAsync((data) {
        expect(
            mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(
            mountRoot.children.first.attributes.containsKey("class"), isTrue);
        expect(
            mountRoot.children.first.attributes.containsKey("text"), isFalse);
      }));
    });

    test("should filter changed attributes on update", () {
      /**
       * one html attribute, one svg and one non of them
       */
      when(component.render())
          .thenReturn([span(props: {"id": "id", "d": "d", "crap": "crap"})]);

      mountComponent(description, mountRoot);

      controller.add(true);
      when(component.render())
          .thenReturn([span(props: {"id": "id2", "d": "d2", "crap": "crap2"})]);

      window.animationFrame.then(expectAsync((data) {
        expect(
            mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isTrue);
        expect(mountRoot.children.first.attributes.containsKey("d"), isFalse);
      }));
    });

    test("should filter added attributes on update in svg component", () {
      /**
       * one html attribute, one svg and one non of them
       */
      when(component.render()).thenReturn([svg(props: {})]);

      mountComponent(description, mountRoot);

      controller.add(true);
      when(component.render())
          .thenReturn([svg(props: {"id": "id2", "d": "d2", "crap": "crap"})]);

      window.animationFrame.then(expectAsync((data) {
        expect(
            mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      }));
    });

    test("should filter changed attributes on update in svg component", () {
      /**
       * one html attribute, one svg and one non of them
       */
      when(component.render())
          .thenReturn([svg(props: {"id": "id", "d": "d", "crap": "crap"})]);

      mountComponent(description, mountRoot);

      controller.add(true);
      when(component.render())
          .thenReturn([svg(props: {"id": "id2", "d": "d2", "crap": "crap2"})]);

      window.animationFrame.then(expectAsync((data) {
        expect(
            mountRoot.children.first.attributes.containsKey("crap"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
        expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      }));
    });

    test("should add props if prev props was null", () {
      String myClass = "myclass";
      int height = 12;

      when(component.render()).thenReturn([span()]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.attributes, isEmpty);

      controller.add(true);
      when(component.render())
          .thenReturn([span(props: {"class": myClass, "height": height})]);

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"), equals(myClass),
            reason: "class should change");
        expect(mountRoot.children.first.getAttribute("height"),
            equals(height.toString()), reason: "haight should be added");
      }));
    });

    test("should remove props if prev props was contains some attributes", () {
      String myClass = "myclass";
      int height = 12;

      when(component.render())
          .thenReturn([span(props: {"class": myClass, "height": height})]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.first.getAttribute("class"), equals(myClass),
          reason: "class should change");
      expect(mountRoot.children.first.getAttribute("height"),
          equals(height.toString()), reason: "haight should be added");

      controller.add(true);
      when(component.render()).thenReturn([span()]);

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.first.attributes, isEmpty);
      }));
    });

    test("should remove all children of removed not dom component", () {
      ComponentMock componentWithSpan = new ComponentMock();
      when(componentWithSpan.render()).thenReturn([span()]);

      when(componentWithSpan.shouldUpdate(any, any)).thenReturn(true);

      ComponentDescriptionMock descriptionWithSpan =
          new ComponentDescriptionMock();
      when(descriptionWithSpan.createComponent()).thenReturn(componentWithSpan);

      when(component.render()).thenReturn([descriptionWithSpan]);

      mountComponent(description, mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(0));

      controller.add(true);
      when(component.render()).thenReturn([]);

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.children.length, equals(0));
      }));
    });

    ComponentMock cmp1;
    ComponentMock cmp2;
    ComponentMock cmp3;

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
      cmp1 = new ComponentMock();
      when(cmp1.needUpdate).thenReturn(controller.stream);
      when(cmp1.shouldUpdate(any, any)).thenReturn(true);

      ComponentDescriptionMock desc1 = new ComponentDescriptionMock();
      when(desc1.createComponent()).thenReturn(cmp1);

      cmp2 = new ComponentMock();
      when(cmp2.shouldUpdate).thenReturn(true);
      ComponentDescriptionMock desc2 = new ComponentDescriptionMock();
      when(desc2.createComponent()).thenReturn(cmp2);

      cmp3 = new ComponentMock();
      when(cmp3.shouldUpdate).thenReturn(true);
      ComponentDescriptionMock desc3 = new ComponentDescriptionMock();
      when(desc3.createComponent()).thenReturn(cmp3);

      when(cmp1.render()).thenReturn([desc2, desc3]);
      when(cmp2.render()).thenReturn([
        div(props: {"id": "div1"}),
        div(props: {"id": "div2"})
      ]); /*div1, div2*/
      when(cmp3.render())
          .thenReturn([div(props: {"id": "div3"}), div(props: {"id": "div4"})]);

      return desc1;
    }

    turn2() {
      when(cmp2.render())
          .thenReturn([div(props: {"id": "div1"}), div(props: {"id": "div2"})]);
      when(cmp3.render()).thenReturn(
          [div(props: {"id": "div3.1"}), div(props: {"id": "div4"})]);
    }

    turn3() {
      when(cmp2.render())
          .thenReturn([div(props: {"id": "div1"}), div(props: {"id": "div2"})]);
      when(cmp3.render()).thenReturn([span(), div()]);
    }

    turn4() {
      when(cmp2.render()).thenReturn(
          [div(props: {"id": "div1"}), span()]); // replace div2 by span
      when(cmp3.render()).thenReturn([span(), div()]);
    }

    test("should only update div attributes when all children are stil div",
        () {
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
      controller.add(true);
      turn2();

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
      controller.add(true);
      turn2();

      window.animationFrame.then(expectAsync((data) {
        controller.add(true);
        turn3();

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
      controller.add(true);
      turn2();
      window.animationFrame.then(expectAsync((data) {
        controller.add(true);
        turn3();

        window.animationFrame.then(expectAsync((data) {
          controller.add(true);
          turn4();

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
      when(spanDescription.createComponent()).thenReturn(spanComponent);

      when(component.render()).thenReturn([spanDescription]);

      mountComponent(description, mountRoot);

      expect(mountRoot.firstChild is SpanElement, isTrue);
      expect(
          getElementForComponent(spanComponent), equals(mountRoot.firstChild));

      Element spanElement = mountRoot.firstChild;

      controller.add(true);
      when(component.render()).thenReturn([]);

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.firstChild, isNull,
            reason: "mountRoot should be empty");
        expect(getElementForComponent(spanComponent), isNull,
            reason: "dependence should be removed");
      }));
    });

    test("should change text inside of html when update of text component ",
        () {
      String text1 = "hello",
          text2 = "aloha";
      when(component.render()).thenReturn(div(children: text1));

      mountComponent(description, mountRoot);

      Text text = mountRoot.firstChild.firstChild;
      expect(text is Text, isTrue);
      expect(text.text, equals(text1));

      controller.add(true);
      when(component.render()).thenReturn(div(children: text2));

      window.animationFrame.then(expectAsync((data) {
        expect(mountRoot.firstChild.firstChild, equals(text));
        expect(text.text, equals(text2));
      }));
    });

    group("($DANGEROUSLYSETINNERHTML)", () {
      test("should update dangerously seted inner HTML", () {
        String text1 = "hello",
            text2 = "aloha";
        when(component.render())
            .thenReturn(div(props: {"dangerouslySetInnerHTML": text1}));

        mountComponent(description, mountRoot);

        Text text = mountRoot.firstChild.firstChild;
        expect(text is Text, isTrue);
        expect(text.text, equals(text1));

        controller.add(true);
        when(component.render())
            .thenReturn(div(props: {"dangerouslySetInnerHTML": text2}));

        window.animationFrame.then(expectAsync((data) {
          text = mountRoot.firstChild.firstChild;
          expect(text is Text, isTrue);
          expect(text.text, equals(text2));
        }));
      });

      test("should update dangerously seted more complex inner HTML", () {
        String text1 = "<span>hello</span><div>helloo</div>",
            text2 = "<div>aloha</div><span>alooha</span>";
        when(component.render())
            .thenReturn(div(props: {"dangerouslySetInnerHTML": text1}));

        mountComponent(description, mountRoot);

        Element divel = mountRoot.firstChild.lastChild;
        Element spanel = mountRoot.firstChild.firstChild;
        expect(divel is DivElement, isTrue);
        expect(spanel is SpanElement, isTrue);
        expect(divel.text, equals("helloo"));
        expect(spanel.text, equals("hello"));

        controller.add(true);
        when(component.render())
            .thenReturn(div(props: {"dangerouslySetInnerHTML": text2}));

        window.animationFrame.then(expectAsync((data) {
          divel = mountRoot.firstChild.firstChild;
          spanel = mountRoot.firstChild.lastChild;
          expect(divel is DivElement, isTrue);
          expect(spanel is SpanElement, isTrue);
          expect(divel.text, equals("aloha"));
          expect(spanel.text, equals("alooha"));
        }));
      });

      test("should create component dangerously seted inner HTML", () {
        String text = "aloha";
        when(component.render()).thenReturn(div());

        mountComponent(description, mountRoot);

        Text innerElement = mountRoot.firstChild.firstChild;
        expect(innerElement, isNull);

        controller.add(true);
        when(component.render()).thenReturn(
            div(children: div(props: {"dangerouslySetInnerHTML": text})));

        window.animationFrame.then(expectAsync((data) {
          innerElement = mountRoot.firstChild.firstChild.firstChild;
          expect(innerElement is Text, isTrue);
          expect(innerElement.text, equals(text));
        }));
      });

      test("should set also href argument", () {
        String text1 = "<p>description sk  </p>",
            text2 =
            '<p>description sk  <a href="http://www.google.com">google</a></p>';
        when(component.render())
            .thenReturn(div(props: {"dangerouslySetInnerHTML": text1}));

        mountComponent(description, mountRoot);

        controller.add(true);
        when(component.render()).thenReturn(div(
            props: {
          DANGEROUSLYSETINNERHTML: text2,
          DANGEROUSLYSETINNERHTMLUNSANITIZE:
              [{"element": "a", "attributes": ["href"]}]
        }));

        window.animationFrame.then(expectAsync((data) {
          expect(
              mountRoot.children.first.children.first.children.first is AnchorElement,
              isTrue);
          expect(mountRoot.children.first.children.first.children.first
              .getAttribute("href"), equals("http://www.google.com"));
        }));
      });
    });
  });
}
