library tiles_dom_elements_special_test;

import 'package:tiles/tiles_dom.dart';
import 'package:tiles/tiles.dart';
import 'package:unittest/unittest.dart';
//import 'package:unittest/mock.dart';
import 'mocks.dart';
//import 'package:tiles/tiles.dart';


main() {
  
  group("(Dom Special Element)", () {
    
    group("(SPAN)", () {
      
      SpanComponent spanComponent;
      
      /**
       * by default, create span without props with content "content"
       */
      setUp(() {
        spanComponent = span(null, "content").createComponent();
      });
      
      test("should be DOM component", () {
        expect(spanComponent is DomComponent, isTrue);
      });
      
      test("should have content", () {
        expect(spanComponent.content(), equals("content"));
      });
      
      test("should return standart children if it has standard children", () {
        ComponentDescription child = new ComponentDescriptionMock();
        var children = [child];
        spanComponent = span(null, children).createComponent();
        
        expect(spanComponent.content(), isNull);
        expect(spanComponent.render(), equals(children));
      });
      
      test("should be surrounding String if is in standart children", () {
        ComponentDescription divCompDesc = div(null, ["content"]);
        spanComponent = divCompDesc.children.first.createComponent();
        
        expect(spanComponent is SpanComponent, isTrue);
        expect(spanComponent.content(), equals("content"));
      });
      
      test("should produce <span>content</span> as markup", () {
        expect("${spanComponent.openMarkup()}${spanComponent.content()}${spanComponent.closeMarkup()}", equals('<span>content</span>'));
      });

      test("should produce <span>content</span> as markup also if props was updated", () {
        spanComponent.props = {"content": "content"};
        expect("${spanComponent.openMarkup()}${spanComponent.content()}${spanComponent.closeMarkup()}", equals('<span>content</span>'));
      });
    });
    
    group("(TEXTAREA)", () {
      TextareaComponent textareaComponent;
      
      String value = "value";
      
      setUp(() {
        textareaComponent = textarea({value: value, "type": "attrValue"}).createComponent();
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
        expect("${textareaComponent.openMarkup()}${textareaComponent.content()}${textareaComponent.closeMarkup()}", 
            equals('<textarea type="attrValue">value</textarea>'));
      });
      
    });
  });
}
