library tiles_dom_elements_special_test;

import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:mock/mock.dart';
import '../mocks.dart';
//import 'package:tiles/tiles.dart';


main() {

  group("(Dom Special Element)", () {

    group("(TEXTAREA)", () {
      TextareaComponent textareaComponent;

      String value = "value";

      setUp(() {
        textareaComponent = textarea(props: {"value": value, "type": "attrValue"}).createComponent();
      });

      test("should be DomComponent", () {
        expect(textareaComponent is DomComponent, isTrue);
      });

      test('should have value in props', () {
        expect(textareaComponent.props["value"], equals(value));
      });

      test('should have value in props when setted by setter', () {
        textareaComponent.props = {value: value};
        expect(textareaComponent.props["value"], equals(value));
      });

      test("should render nothing, evet if it has children", () {
        textareaComponent.children = [];

        expect(textareaComponent.children, equals([]));

        expect(textareaComponent.render(), isNull);
      });

    });
  });
}
