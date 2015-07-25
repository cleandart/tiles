library tiles_test.server;

import 'package:test/test.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_console.dart';
import '../mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/src/dom/dom_attributes.dart';

main() {
  group("(Server side rendering)", () {
    test("should contain method renderToString", () {
      expect(renderToString, isNotNull);
    });

    ComponentDescription description;
    setUp(() {
      description = new ComponentDescriptionMock();
    });

    mockComponent(Component component) {
      when(description.createComponent()).thenReturn(component);
    }

    group("(DOM)", () {
      DomComponent domComponent;

      initComponent({Map props, bool pair: true, children}) {
        domComponent = new DomComponent(
            tagName: "tag", pair: pair, props: props, children: children);
        mockComponent(domComponent);
      }
      test("should render simple pair dom component without prosp", () {
        initComponent();
        expect(renderToString(description), equals("<tag></tag>"));
      });

      test("should render simple not pair dom component without props", () {
        initComponent(pair: false);
        expect(renderToString(description), equals("<tag />"));
      });

      group("(props)", () {
        test("should render props for pair component", () {
          initComponent(props: {"class": "something"});
          expect(renderToString(description),
              equals('<tag class="something"></tag>'));
        });
        test("should render props for not pair component", () {
          initComponent(props: {"class": "something"}, pair: false);
          expect(
              renderToString(description), equals('<tag class="something" />'));
        });

        test("should render prefixed props", () {
          initComponent(props: {"data-whatever": "something"}, pair: false);
          expect(renderToString(description),
              equals('<tag data-whatever="something" />'));
        });

        test("should not render not allowed props", () {
          initComponent(props: {"whatever": "something"}, pair: false);
          expect(renderToString(description), equals('<tag />'));
        });

        test("should render default value as value", () {
          initComponent(props: {DEFAULTVALUE: "default-value"}, pair: false);
          expect(renderToString(description),
              equals('<tag value="default-value" />'));
        });
        test("should render only value, also if have default value", () {
          initComponent(
              props: {DEFAULTVALUE: "default-value", "value": "value"},
              pair: false);
          expect(renderToString(description), equals('<tag value="value" />'));
        });
      });

      group("(children)", () {
        ComponentDescriptionMock childDescription;

        addComponent(component) {
          childDescription = new ComponentDescriptionMock();
          when(childDescription.createComponent()).thenReturn(component);
        }

        test("should render children", () {
          addComponent(new DomComponent(tagName: "child"));

          initComponent(children: [childDescription]);

          expect(renderToString(description),
              equals("<tag><child></child></tag>"));
        });

        test("should render children with props", () {
          addComponent(
              new DomComponent(tagName: "child", props: {"class": "myclass"}));

          initComponent(children: [childDescription]);

          expect(renderToString(description),
              equals('<tag><child class="myclass"></child></tag>'));
        });

        test("should render children with props and without not allowed props",
            () {
          addComponent(new DomComponent(
              tagName: "child",
              props: {"test": "attribute", "class": "myclass"}));

          initComponent(children: [childDescription]);

          expect(renderToString(description),
              equals('<tag><child class="myclass"></child></tag>'));
        });

        test("should render children for children", () {
          addComponent(new DomComponent(tagName: "innerChild"));
          var innerChildDescription = childDescription;
          addComponent(new DomComponent(
              tagName: "child", children: [innerChildDescription]));

          initComponent(children: [childDescription]);

          expect(renderToString(description),
              equals('<tag><child><innerChild></innerChild></child></tag>'));
        });

        test("should render multiple child", () {
          addComponent(new DomComponent(tagName: "innerChild"));
          var innerChildDescription = childDescription;
          addComponent(new DomComponent(tagName: "innerChild2"));
          var innerChildDescription2 = childDescription;
          addComponent(new DomComponent(
              tagName: "child",
              children: [innerChildDescription, innerChildDescription2]));

          initComponent(children: [childDescription]);

          expect(renderToString(description), equals(
              '<tag><child><innerChild></innerChild><innerChild2></innerChild2></child></tag>'));
        });
      });
    });

    group("(text component)", () {
      test("should render text component as test", () {
        mockComponent(new DomTextComponent("text"));

        expect(renderToString(description), equals("text"));
      });
      test("should render text inside div", () {
        expect(
            renderToString(div(children: "text")), equals("<div>text</div>"));
      });
    });

    group("(textarea component)", () {
      test("shoudl render with content from value", () {
        expect(renderToString(textarea(props: {"value": "value"})),
            equals("<textarea>value</textarea>"));
      });

      test("shoudl render with content from defalt value", () {
        expect(renderToString(textarea(props: {DEFAULTVALUE: "default-value"})),
            equals("<textarea>default-value</textarea>"));
      });

      test("shoudl render with content from value if have default value also",
          () {
        expect(renderToString(textarea(
                props: {DEFAULTVALUE: "default-value", "value": "value"})),
            equals("<textarea>value</textarea>"));
      });
      test("should ignore children", () {
        expect(renderToString(textarea(children: [div()])),
            equals("<textarea></textarea>"));
      });
    });

    group("(custom component)", () {
      mockComponent(Component component) {
        when(description.createComponent()).thenReturn(component);
      }

      test("should render custom component as empty string", () {
        mockComponent(new Component(null));

        expect(renderToString(description), equals(""));
      });

      test("should render children of custom component", () {
        ComponentMock component = new ComponentMock();
        when(component.render()).thenReturn([div()]);
        mockComponent(component);
        expect(renderToString(description), equals('<div></div>'));
      });
    });

    test("more complex example", () {
      expect(renderToString(customComponent(
          children: div(
              props: {"class": "firstDiv"},
              children: customComponent(
                  children: ["test",
        span(),
        textarea(props: {"defaultValue": "value"})
      ])))), equals('<div class="firstDiv">test<span></span><textarea>value</textarea></div>'));
    });
  });
}

class CustomComponent extends Component {
  CustomComponent(props, children) : super(props, children);

  render() => children;
}

ComponentDescriptionFactory customComponent = registerComponent(
    ({props, children}) => new CustomComponent(props, children));
