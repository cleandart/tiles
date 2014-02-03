library tiles_dom_elements_test;

import 'package:tiles/tiles_dom.dart';
import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import 'mocks.dart';
//import 'package:tiles/tiles.dart';


main() {
  
  group("(DOM elements)", () {
    var element = div;
    var notPairElement = link;
    
    test("dom component description factories create factories with different ComponentFactory", () {
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
    
    test("component produced should be instance of DomComponent", () {
      expect(element().createComponent() is DomComponent, isTrue);
    });
    
    test("nested rendering", () {
      ComponentDescription aa = a({}, [div(null, [span(), span()]), div()]);
      Component aaa = aa.createComponent();
      
      DomComponent innerSpan = aaa.render()[0].createComponent().render()[0].createComponent(); 
      
      expect(innerSpan.openMarkup(), contains("span"));
    });
    
    test("div should not produce svg component", () {
      DomComponent divComponent = div().createComponent();
      
      expect(divComponent.svg, isFalse);
    });

    test("svg should produce svg component", () {
      DomComponent svgComponent = svg().createComponent();
      
      expect(svgComponent.svg, isTrue);
    });
    
    test ("div should show id attribute and not d atribute", () {
      DomComponent divCompoennt = div({"id": "id", "d": "d"}).createComponent();
      
      expect(divCompoennt.openMarkup(), equals('<div id="id">'));
    });

    test ("svg should show d attribute and not id atribute", () {
      DomComponent svgCompoennt = svg({"id": "id", "d": "d"}).createComponent();
      
      expect(svgCompoennt.openMarkup(), equals('<svg d="d">'));
    });

  });
  
}

