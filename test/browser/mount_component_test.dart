library tiles_mount_component_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'dart:html';
import '../mocks.dart';
import 'dart:convert';

main() {
  group("(browser) (mountComponent)", () {
    Element mountRoot;
    
    setUp(() {
      mountRoot = new Element.div();
      
      /**
       * uncomment to see what theese test do in browser
       */
//      querySelector("body").append(mountRoot);
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
      String src = "https: //encrypted-tbn2.gstatic.com/images?q=tbn: ANd9GcRoEfjv0a02ICVrPaGrveSlhiCHj4pfnvXHd4Eh324FlWT_xUVTDPwQCg6-";
      mountComponent(img({
        "src": src,
        "style": "height: 500px;",
          }), mountRoot);
      
      expect(mountRoot.children.length, equals(1));

      ImageElement image = mountRoot.children.first;
      expect(image is ImageElement, isTrue);
      expect(image.attributes["src"], equals(_htmlEscape.convert(src)));
    });
    
    test("should skip not DomComponent Component", () {
      ComponentMock component = new ComponentMock();
      component.when(callsTo("render")).alwaysReturn([span()]);
      
      ComponentDescriptionMock description = new ComponentDescriptionMock();
      description.when(callsTo("createComponent")).alwaysReturn(component);
      
      mountComponent(description, mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first is SpanElement, isTrue);
      expect(mountRoot.children.first.children.isEmpty, isTrue);
    });
    
    test("should write all children of children into element, if first level children was not dom components", () {
      ComponentMock component1 = new ComponentMock();
      component1.when(callsTo("render")).alwaysReturn([span()]);
      
      ComponentDescriptionMock description1 = new ComponentDescriptionMock();
      description1.when(callsTo("createComponent")).alwaysReturn(component1);
      
      ComponentMock component2 = new ComponentMock();
      component2.when(callsTo("render")).alwaysReturn([img()]);
      
      ComponentDescriptionMock description2 = new ComponentDescriptionMock();
      description2.when(callsTo("createComponent")).alwaysReturn(component2);
      
      mountComponent(div(null, [description1, description2]), mountRoot);
      
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
    
  });
}

HtmlEscape _htmlEscape = new HtmlEscape();
