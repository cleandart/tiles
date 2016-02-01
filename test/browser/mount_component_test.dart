library tiles_mount_component_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';

import 'mount_use_existing_test.dart' as useExisting;
import 'package:tiles/src/dom/dom_attributes.dart';

main() {
  group("(browser) (mountComponent)", () {
    Element mountRoot;
    String imageSource =
        "http://github.global.ssl.fastly.net/images/modules/logos_page/GitHub-Mark.png";

    ComponentDescriptionMock descriptionWithSpan;
    ComponentDescriptionMock descriptionWithImage;
    ComponentMock componentWithSpan;
    ComponentMock componentWithImage;

    try {
      initTilesBrowserConfiguration();
    } catch (e) {}

    setUp(() {
      /**
       * create new mountRoot
       */
      mountRoot = new Element.div();

      /**
       * Prepare descriptions
       */

      componentWithSpan = new ComponentMock();
      when(componentWithSpan.render()).thenReturn([span()]);

      descriptionWithSpan = new ComponentDescriptionMock();
      when(descriptionWithSpan.createComponent())
          .thenReturn(componentWithSpan);

      componentWithImage = new ComponentMock();
      when(componentWithImage.render()).thenReturn([img()]);

      descriptionWithImage = new ComponentDescriptionMock();
      when(descriptionWithImage.createComponent())
          .thenReturn(componentWithImage);

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);
    });

    test("should exist such function", () {
      mountComponent(div(), mountRoot);
    });

    test("should create div element if mount div()", () {
      mountComponent(div(), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.tagName, equals("DIV"));
    });

    test("should create div element if mount div()", () {
      mountComponent(div(props: {"class": "divclass"}), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(
          mountRoot.children.first.attributes["class"], contains("divclass"));
    });

    test("should create 2 level children if passed 2 level of dom components",
        () {
      mountComponent(div(children: div()), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(1));
    });

    test("should create 3 level children if passed 2 level of dom components",
        () {
      mountComponent(div(children: div(children: div())), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(1));
      expect(
          mountRoot.children.first.children.first.children.length, equals(1));
    });

    test(
        "should create second level with 2 elements if passed such cescriptions",
        () {
      mountComponent(div(children: [div(), div()]), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(2));
    });

    test("sould create div with text, if is that passed to it", () {
      mountComponent(div(children: "text"), mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.childNodes.length, equals(1));
      expect(mountRoot.children.first.childNodes.first is Text, isTrue);
    });

    test("should create image if image passed", () {
      mountComponent(
          img(props: {"src": imageSource, "style": "height: 500px;",}),
          mountRoot);

      expect(mountRoot.children.length, equals(1));

      ImageElement image = mountRoot.children.first;
      expect(image is ImageElement, isTrue);
      expect(image.attributes["src"], equals(imageSource));
    });

    test("should skip not DomComponent Component", () {
      mountComponent(descriptionWithSpan, mountRoot);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first is SpanElement, isTrue);
      expect(mountRoot.children.first.children.isEmpty, isTrue);
    });

    test(
        "should write all children of children into element, if first level children was not dom components",
        () {
      mountComponent(div(children: [descriptionWithSpan, descriptionWithImage]),
          mountRoot);

      expect(mountRoot.children.length, equals(1));
      Element el = mountRoot.children.first;
      expect(el is DivElement, isTrue);
      expect(el.children.length, equals(2));
      expect(el.children.first is SpanElement, isTrue);
      expect(el.children.last is ImageElement, isTrue);
    });

    test("should clear element", () {
      mountRoot.children
          .addAll([new DivElement(), new ImageElement(), new SpanElement()]);

      mountComponent(b(), mountRoot);

      expect(mountRoot.children.length, equals(1));
    });

    test(
        "if component have ref callback in props, it should be called with component instance when it is completely mounted",
        () {
      var props = {};

      props["ref"] = expectAsync((Component component) {
        expect(component, equals(componentWithSpan));
      });

      when(componentWithSpan.props).thenReturn(props);

      mountComponent(descriptionWithSpan, mountRoot);
      expect(descriptionWithSpan.createComponent(), equals(componentWithSpan));
      expect(descriptionWithSpan.createComponent().props, equals(props));
    });

    test("should work if component not have props", () {
      when(componentWithSpan.props).thenReturn(null);

      /**
       * just test, if no exception is thrown
       */
      expect(
          () => mountComponent(descriptionWithSpan, mountRoot), isNot(throws));
    });

    test("should work with something weird in props ref", () {
      var props = {};
      props["ref"] = new Mock();
      when(componentWithSpan.props).thenReturn(props);

      expect(
          () => mountComponent(descriptionWithSpan, mountRoot), isNot(throws));
    });

    test("should add only allowed attributes", () {
      var props = {"d": "d", "crap": "crap", "id": "id"};

      mountComponent(span(props: props), mountRoot);

      expect(mountRoot.children.first is SpanElement, isTrue);
      expect(mountRoot.children.first.attributes.containsKey("id"), isTrue);
      expect(mountRoot.children.first.attributes["id"], equals("id"));
      expect(mountRoot.children.first.attributes.containsKey("d"), isFalse);
      expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
    });

    test("should add only allowed svg attributes for svg element", () {
      var props = {"d": "d", "crap": "crap", "id": "id"};

      mountComponent(svg(props: props), mountRoot);

      expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      expect(mountRoot.children.first.attributes["d"], equals("d"));
      expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
      expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
    });
    
    test("should add attributes with allowed prefixes", () {
      var props = {"aria-something": "aria", "data-somethingelse": "data", "wrong-else": "wrong"};

      mountComponent(div(props: props), mountRoot);

      expect(mountRoot.children.first.attributes.containsKey("aria-something"), isTrue);
      expect(mountRoot.children.first.attributes["aria-something"], equals("aria"));
      
      expect(mountRoot.children.first.attributes.containsKey("data-somethingelse"), isTrue);
      expect(mountRoot.children.first.attributes["data-somethingelse"], equals("data"));
      
      expect(mountRoot.children.first.attributes.containsKey("wrong-else"), isFalse);
    });

    group("(remount)", () {
      var children1 = div(children: span(props: {"id": "id1"}));
      var children2 = div(children: span(props: {"id": "id2"}));

      Element divEl;
      Element spanEl;

      void _saveElements() {
        divEl = mountRoot.children.first;
        spanEl = divEl.children.first;
      }

      void checkRemount(Element mountRoot, Element divEl, Element spanEl) {
        window.animationFrame.then(expectAsync((_) {
          expect(mountRoot.children.first, equals(divEl));
          expect(mountRoot.children.first.children.first, equals(spanEl));
          expect(mountRoot.children.first.children.first.attributes["id"],
              equals("id2"));
        }));
      }

      ComponentMock component;
      ComponentDescription _createMockDescription() {
        ComponentDescriptionMock description = new ComponentDescriptionMock();
        component = new ComponentMock();

        var factory = ({props, children}) => component;
        var listeners = {"onClick": (_, __) {}};
        var props = {"key": "value"};

        when(description.factory).thenReturn(factory);
        when(description.createComponent()).thenReturn(component);
        when(description.props).thenReturn(props);
        when(description.listeners).thenReturn(listeners);
        when(description.children).thenReturn(null);

        when(component.render())
            .thenReturn(children1);
        
        return description;
      }
      
      void nextRender() {
        when(component.render())
            .thenReturn(children2);
      }

      test("should only remount on second mount of the same dom component", () {
        mountComponent(children1, mountRoot);

        _saveElements();

        mountComponent(children2, mountRoot);

        checkRemount(mountRoot, divEl, spanEl);
      });

      test("should only remount on second mount of same custom component", () {
        ComponentDescriptionMock description = _createMockDescription();

        mountComponent(description, mountRoot);

        _saveElements();
        nextRender();

        mountComponent(description, mountRoot);

        checkRemount(mountRoot, divEl, spanEl);
      });
    });


    group("($DANGEROUSLYSETINNERHTML)", () {
      
      test("should dangorously insert inner HTML", () {
        mountRoot = new DivElement();
        mountComponent(div(props:{DANGEROUSLYSETINNERHTML: "<span class='cl'>hello</span>"}), mountRoot);
        
        expect(mountRoot.children.first.children.first is SpanElement, isTrue);
      });
      
      test("should throw if want to set inner html and also have childre", () {
        mountRoot = new DivElement();

        expect(() {
          mountComponent(div(children: "hello", props:{DANGEROUSLYSETINNERHTML: "<span class='cl'>hello</span>"}), mountRoot);
        }, throws);
      });
      
      test("should set aso href argument", () {
        mountRoot = new DivElement();
        querySelector("body").append(mountRoot);
        mountComponent(div(props:{
          DANGEROUSLYSETINNERHTML: '<p>description sk  <a href="http://www.google.com">google</a></p>',
          DANGEROUSLYSETINNERHTMLUNSANITIZE: [{
            "element": "a",
            "attributes": ["href"],
            "uriPolicy": r".*",
          }],
        }), mountRoot);
        
        expect(mountRoot.children.first.children.first.children.first is AnchorElement, isTrue);
        expect(mountRoot.children.first.children.first.children.first.getAttribute("href"), equals("http://www.google.com"));
      });
          
    });
    
    group("(clearNotUsed)", () {
      
      test("should mount component without clearig mount root",  () {
        mountRoot.children.add(new SpanElement());
        
        mountComponent(div(), mountRoot, clearNotUsed: false);
        
        expect(mountRoot.children.last is SpanElement, isTrue);
        expect(mountRoot.children.first is DivElement, isTrue);
      });
      
      test("should be able to mount to head", () {
        var head = querySelector("head");
        mountComponent(div(), head, clearNotUsed: false);
        
        expect(head, isNotNull);
        expect(head.firstChild is DivElement, isTrue);
      });
      
      test("should be possible to mount to html", () {
        var html = querySelector("html");
        mountComponent(div(), html, clearNotUsed: false);
        
        expect(html.firstChild is DivElement, isTrue);
      });
    });
    
    useExisting.main();
});

  group("(browser) (unmountComponent)", () {
    Element mountRoot;
    setUp(() {
      mountRoot = new DivElement();
      querySelector("body").append(mountRoot);

      mountComponent(div(), mountRoot);
    });
    test("should remove whole markup", () {
      unmountComponent(mountRoot);
      expect(mountRoot.children, isEmpty);
    });

    test("should remove whole markup when custom componet was mounted", () {
      ComponentMock component = new ComponentMock();
      when(component.render()).thenReturn([div()]);

      ComponentDescriptionMock description = new ComponentDescriptionMock();
      when(description.createComponent()).thenReturn(component);

      mountComponent(description, mountRoot);
      unmountComponent(mountRoot);

      expect(mountRoot.children, isEmpty);
    });

    test("should remove relation between component and element on unmount", () {
      Component divComponent = new DomComponent(tagName: "div");
      ComponentDescriptionMock divDescription = new ComponentDescriptionMock();
      when(divDescription.createComponent())
          .thenReturn(divComponent);

      mountComponent(divDescription, mountRoot);
      unmountComponent(mountRoot);

      expect(getElementForComponent(divComponent), isNull);
    });
    
  });
}
