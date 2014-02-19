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
      
      controller.close().then(expectAsync((something) {
        expect(mountRoot.children.length, equals(1));
        expect(mountRoot.children.first is ImageElement, isTrue);
      }));
    });

    test("should replace only inner element, which should be replaced", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(null, span()), div()];
        })
        .thenCall(() {
          return [div(null, img()), div()];
        });
      
      mountComponent(description, mountRoot);
      
      
      component.redraw();
      
      expect(mountRoot.children.first.children.length, equals(1));
      expect(mountRoot.children.first.children.first is SpanElement, isTrue, reason: "div should contain span");
      
      var dd = mountRoot.childNodes.first;

      controller.close().then(expectAsync((something) {
        expect(mountRoot.children.length, equals(2));
        expect(mountRoot.children.first, equals(dd));
        expect(mountRoot.children.first.children.length, equals(1));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });
    
    test("should replace element at place", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(null, [span(), span()])];
        })
        .thenCall(() {
          return [div(null, [img(), span()])];
        });
      
      mountComponent(description, mountRoot);
      
      component.redraw();
      
      Element sp = mountRoot.children.first.children.last;
      
      controller.close().then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children.first is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });
    
    test("should replace 2 elements at place", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(null, [span(), span(), span()])];
        })
        .thenCall(() {
          return [div(null, [div(), img(), span()])];
        });
      
      mountComponent(description, mountRoot);
      
      component.redraw();
      
      Element sp = mountRoot.children.first.children.last;
      
      controller.close().then(expectAsync((something) {
        expect(mountRoot.children.first.children.last, equals(sp));
        expect(mountRoot.children.first.children[0] is DivElement, isTrue, reason: "span should be replaced by image");
        expect(mountRoot.children.first.children[1]is ImageElement, isTrue, reason: "span should be replaced by image");
      }));
    });
    
    test("should replace elements properly in more complicated example", () {
      component.when(callsTo("render"))
        .thenCall(() {
          return [div(null, [
                    span(), 
                    span(), 
                    span(null, 
                      div(null, [
                        span(), 
                        div(),
                        img(),
                        a()
                      ])),
                    span()
                 ])];
        })
        .thenCall(() {
          return [div(null, [
                    div(), 
                    img(), 
                    span(null, 
                      div(null, [
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
      
      controller.close().then(expectAsync((something) {
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
        .thenReturn([span({"class": myClass, "id": id})])
        .thenReturn([span({"class": myOtherClass, "height": height})]);

      mountComponent(description, mountRoot);
      
      expect(mountRoot.children.first.getAttribute("class"), equals(myClass));
      expect(mountRoot.children.first.getAttribute("id"), equals(id));
      expect(mountRoot.children.first.attributes.containsKey("height"), isFalse, reason: "should not contain height");
      component.redraw();
      
      controller.close().then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"), equals(myOtherClass), reason: "class should change");
        expect(mountRoot.children.first.attributes.containsKey("id"), isFalse, reason: "id should be removed");
        expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");
      }));
    });
    
    test("should add props if prev props was null", () {
      String myClass = "myclass";
      int height = 12; 
      
      component.when(callsTo("render"))
        .thenReturn([span()])
        .thenReturn([span({"class": myClass, "height": height})]);

      mountComponent(description, mountRoot);
      
      expect(mountRoot.children.first.attributes, isEmpty);

      component.redraw();
      
      controller.close().then(expectAsync((data) {
        expect(mountRoot.children.first.getAttribute("class"), equals(myClass), reason: "class should change");
        expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");
      }));
    });

    test("should remove props if prev props was contains some attributes", () {
      String myClass = "myclass";
      int height = 12; 
      
      component.when(callsTo("render"))
        .thenReturn([span({"class": myClass, "height": height})])
        .thenReturn([span()]);

      mountComponent(description, mountRoot);
      
      expect(mountRoot.children.first.getAttribute("class"), equals(myClass), reason: "class should change");
      expect(mountRoot.children.first.getAttribute("height"), equals(height.toString()), reason: "haight should be added");

      component.redraw();
      
      controller.close().then(expectAsync((data) {
        expect(mountRoot.children.first.attributes, isEmpty);
      }));
    });
    
    test("should remove all children of removed not dom component", () {
      ComponentMock componentWithSpan = new ComponentMock();
      componentWithSpan.when(callsTo("render")).alwaysReturn([span()]);
      
      ComponentDescriptionMock descriptionWithSpan = new ComponentDescriptionMock();
      descriptionWithSpan.when(callsTo("createComponent")).alwaysReturn(componentWithSpan);
      
      component.when(callsTo("render"))
        .thenReturn([descriptionWithSpan])
        .thenReturn([]);
      
      mountComponent(description, mountRoot);
      
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.children.first.children.length, equals(0));
      
      component.redraw();
      
      controller.close().then(expectAsync((data) {
        expect(mountRoot.children.length, equals(0));
      }));
    });
    
  });
}

