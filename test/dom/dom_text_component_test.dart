library tiles_dom_text_component_test;

import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';


main() {
  
  group("(DOM DomTextComponent)", () {
    DomTextComponent component;
    String text;
    ComponentDescriptionFactory factory;
    ComponentDescription desc;

    
    setUp(() {
      text = "text";
      component = new DomTextComponent(text);
      factory = registerComponent(([props, children]) => new Component(props, children));
    });
    
    test("should have working constructor with one String parameter as props", () {
      component = new DomTextComponent("");
      
      expect(component, isNotNull);
    });
    
    test("should return string from constructor as props and as text", () {
      component = new DomTextComponent(text);
      
      expect(component.props, equals(text));
    });
    
    test("should have settable props", () {
      String otherText = "otherText"; 
      component.props = otherText;
      
      expect(component.props, equals(otherText));
    });
    
    /**
     * method that checks, if only one child in description is DomTextComponent with text as props 
     */
    _expectTextComponentInChildren(ComponentDescription desc) {
      expect(desc.children.length, equals(1));
      expect(desc.children.first.props, equals(text));
      expect(desc.children.first.createComponent() is DomTextComponent, isTrue);
    };

    test("should surround string child passed to DOM element", () {
      desc = span(null, [text]);
      
      _expectTextComponentInChildren(desc);
    });
    
    test("should surround string passed to DOM element as children", () {
      desc = span(null, text);

      _expectTextComponentInChildren(desc);
    });
    
    test("should surround text passed as children to ComponentDescriptionFactory created by registerComponent", () {
      desc = factory(null, [text]);
      
      _expectTextComponentInChildren(desc);
    });
    
    test("should surround text passed as child to ComponentDescriptionFactory created by registerComponent", () {
      desc = factory(null, text);
      
      _expectTextComponentInChildren(desc);
    });
    
    test("should surround also other then only one child", () {
      desc = factory(null, [span(), text]);
      
      expect(desc.children.last.props, equals(text));
    });
    
  });

}


