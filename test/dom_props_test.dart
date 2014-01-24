library tiles_dom_props_test;

import 'package:tiles/tiles_dom.dart';
import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
import 'mocks.dart';

main(){
  group("(DomProps)", () {
    DomProps props;
    ComponentDescription desc = new ComponentDescriptionMock();
    List<ComponentDescription> children = [desc];
    
    test("Constructor without map", () {
      props = new DomProps();
      
      expect(props.isEmpty, isTrue);
      expect(props["something"], isNull);
    });
    
    test("constructor with not empty map", () {
      props = new DomProps({"something": "something"});
      
      expect(props["something"], equals("something"));
    });
    
    test("constructor with map children and map", () {
      props = new DomProps({}, []); 
    });
    
    test("constructor with not empty children", () {
      props = new DomProps(null, children);
      
      expect(props.children, equals(children));
    });
    
    test("constructor with children in map", () {
      props = new DomProps({"children": children});
      
      expect(props.children, equals(children));
      
    });
    
    test("generate html attribute list from instance - 1 attribute", () {
      props = new DomProps({"attr":"value"});
      
      expect(props.htmlAttrs(), equals(' attr="value"'));
    });

    test("generate html attribute list from instance - 2 attributes", () {
      props = new DomProps({"attr":"value", "attr2": "value2"});
      
      expect(props.htmlAttrs(), equals(' attr="value" attr2="value2"'));
    });
    
    test("empty map shoult produce empty stirng of html attris", () {
      props = new DomProps();
      
      expect(props.htmlAttrs(), equals(''));
    });
  });
}