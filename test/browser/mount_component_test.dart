library tiles_mount_component_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';

main() {
  group("(browser) (mountComponent)", () {
    Element mountRoot;
    String imageSource = "http: //github.global.ssl.fastly.net/images/modules/logos_page/GitHub-Mark.png";
    
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
      componentWithSpan.when(callsTo("render")).alwaysReturn([span()]);
      
      descriptionWithSpan = new ComponentDescriptionMock();
      descriptionWithSpan.when(callsTo("createComponent")).alwaysReturn(componentWithSpan);
      
      componentWithImage = new ComponentMock();
      componentWithImage.when(callsTo("render")).alwaysReturn([img()]);
      
      descriptionWithImage = new ComponentDescriptionMock();
      descriptionWithImage.when(callsTo("createComponent")).alwaysReturn(componentWithImage);

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
      mountComponent(div({"class": "divclass"}), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.attributes["class"], contains("divclass"));
    });
    
    test("should create 2 level children if passed 2 level of dom components", () {
      mountComponent(div(null, div()), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(1));
    });
    
    test("should create 3 level children if passed 2 level of dom components", () {
      mountComponent(div(null, div(null, div())), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(1));
      expect(mountRoot.children.first.children.first.children.length, equals(1));
    });
    
    test("should create second level with 2 elements if passed such cescriptions", () {
      mountComponent(div(null, [div(), div()]), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(2));
    });
    
    test("sould create div with text, if is that passed to it", () {
      mountComponent(div(null, "text"), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.childNodes.length, equals(1));
      expect(mountRoot.children.first.childNodes.first is Text, isTrue);
    });
    
    test("should create image if image passed", () {
      mountComponent(img({
        "src": imageSource,
        "style": "height: 500px;",
          }), mountRoot);
      
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
    
    test("should write all children of children into element, if first level children was not dom components", () {
      mountComponent(div(null, [descriptionWithSpan, descriptionWithImage]), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      Element el = mountRoot.children.first;
      expect(el is DivElement, isTrue);
      expect(el.children.length, equals(2));
      expect(el.children.first is SpanElement, isTrue);
      expect(el.children.last is ImageElement, isTrue);
    });
    
    test("should clear element", () {
      mountRoot.children.addAll([new DivElement(), new ImageElement(), new SpanElement()]);
      
      mountComponent(b(), mountRoot);
      
      expect(mountRoot.children.length, equals(1));
    });
    
    test("if component have ref callback in props, it should be called with component instance when it is completely mounted", () {
      var props = {};
      
      props["ref"] = expectAsync((Component component) {
        expect(component, equals(componentWithSpan));
      });
      
      componentWithSpan.when(callsTo("get props")).alwaysReturn(props);
      
      mountComponent(descriptionWithSpan, mountRoot);
      expect(descriptionWithSpan.createComponent(), equals(componentWithSpan));
      expect(descriptionWithSpan.createComponent().props, equals(props));
    });
    
    test("should work if component not have props", () {
      componentWithSpan.when(callsTo("get props")).alwaysReturn(null);
      
      /**
       * just test, if no exception is thrown
       */
      expect(() => mountComponent(descriptionWithSpan, mountRoot), isNot(throws));
    });
    
    test("should work with something weird in props ref", () {
      var props = {};
      props["ref"] = new Mock();
      componentWithSpan.when(callsTo("get props")).alwaysReturn(props);

      expect(() => mountComponent(descriptionWithSpan, mountRoot), isNot(throws));
    });
    
    test("should add only allowed attributes", () {
      var props = {"d": "d", "crap": "crap", "id": "id"};
      
      mountComponent(span(props), mountRoot);
      
      expect(mountRoot.children.first is SpanElement, isTrue);
      expect(mountRoot.children.first.attributes.containsKey("id"), isTrue);
      expect(mountRoot.children.first.attributes["id"], equals("id"));
      expect(mountRoot.children.first.attributes.containsKey("d"), isFalse);
      expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
    });
    
    test("should add only allowed svg attributes for svg element", () {
      var props = {"d": "d", "crap": "crap", "id": "id"};
      
      mountComponent(svg(props), mountRoot);
      
      expect(mountRoot.children.first.attributes.containsKey("d"), isTrue);
      expect(mountRoot.children.first.attributes["d"], equals("d"));
      expect(mountRoot.children.first.attributes.containsKey("id"), isFalse);
      expect(mountRoot.children.first.attributes.containsKey("crap"), isFalse);
    });
    
  });
}
