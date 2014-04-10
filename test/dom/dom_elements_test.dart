library tiles_dom_elements_test;

import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import '../mocks.dart';
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

    test("should accept map as props and save it to props", () {
      DomComponent elementComponent = element(props: {"attr": "value"}).createComponent();

      expect(elementComponent.props["attr"], equals("value"));
    });

    test("html element with children", () {
      ComponentDescription child = new ComponentDescriptionMock();
      List<ComponentDescription> children = [child];

      DomComponent elementComponent = element(children: children).createComponent();

      expect(elementComponent.children, equals(children));
    });

    test("component produced should be instance of DomComponent", () {
      expect(element().createComponent() is DomComponent, isTrue);
    });

    test("nested rendering", () {
      ComponentDescription aa = a(props: {}, children: [div(children: [span(), span()]), div()]);
      Component aaa = aa.createComponent();

      DomComponent innerSpan = aaa.render()[0].createComponent().render()[0].createComponent();

      expect(innerSpan.tagName, equals("span"));
    });

    test("div should not produce svg component", () {
      DomComponent divComponent = div().createComponent();

      expect(divComponent.svg, isFalse);
    });

    test("svg should produce svg component", () {
      DomComponent svgComponent = svg().createComponent();

      expect(svgComponent.svg, isTrue);
    });

    test("should create null listeners by default", () {
      ComponentDescription description = div();

      expect(description.listeners, isNull);
    });

    test("should support listeners", () {
      ComponentDescription description = div(listeners: {});

      expect(description.listeners, isNotNull);
    });

  });

}

