library tiles_dom_elements_test;

import 'package:tiles/tiles_dom.dart';
import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import 'mocks.dart';
//import 'package:tiles/tiles.dart';


main(){
  
  group("(DOM elements)", () {
    var element = div;
    var notPairElement = link;
    
    test("dom component description factories create factories with different ComponentFactory", (){
      ComponentFactory notPairElementFactory = notPairElement().factory;
      ComponentFactory elementFactory = element().factory;

      expect(notPairElementFactory, isNot(equals(elementFactory)));
     });
    
    test("test not pair elements (for example link, input, line)", () {
      DomComponent notPairElementComponent = notPairElement().createComponent();
      expect(notPairElementComponent.pair, equals(false));
    });
    
    test("link markup", () {
      DomComponent linkComponent = link().createComponent();
      
      expect(linkComponent.openMarkup(), equals("<link />"));
    });
    
    test("when get map instead of props, convert it to DomProps", () {
      DomComponent elementComponent = element({"attr": "value"}).createComponent();
      
      expect(elementComponent.props["attr"], equals("value"));
    });
    
    test("html element with props as map and children", () {
      ComponentDescription child = new ComponentDescriptionMock();
      List<ComponentDescription> children = [child];
      
      DomComponent elementComponent = element({"attr": "value"}, children).createComponent();
      
      expect(elementComponent.props.children, equals(children));
    });
    
    test("component produced should be instance of DomComponent", (){
      expect(element().createComponent() is DomComponent, isTrue);
    });

  });
  
}