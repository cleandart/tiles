library tiles_dom_elements_special_test;

import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import '../mocks.dart';
//import 'package:tiles/tiles.dart';


main() {
  
  group("(Dom Special Element)", () {
    
    group("(TEXTAREA)", () {
      TextareaComponent textareaComponent;
      
      String value = "value";
      
      setUp(() {
        textareaComponent = textarea({"value": value, "type": "attrValue"}).createComponent();
      });
      
      test("should be DomComponent", () {
        expect(textareaComponent is DomComponent, isTrue);
      });
      
      test('should return in content what it gets in prosp["value"]', () {
        expect(textareaComponent.content(), equals(value));
      });

      test('should remove value from props', () {
        expect(textareaComponent.props[value], isNull);
      });
      
      test('should remove value from props when setted by setter', () {
        textareaComponent.props = {value: value};
        expect(textareaComponent.props[value], isNull);
      });
      
      test('should return <textarea type="attrValue">value</textarea> as .openMarkup() .content() .closeMarkup', () {
        expect(textareaComponent.content(), equals("value"));
        expect(textareaComponent.props.containsKey("value"), isFalse);
      });
      
    });
  });
}
