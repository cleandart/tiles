import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:library/library.dart';

class ComponentDescriptionMock extends Mock implements ComponentDescription {}

main() {
  group("(Props)", (){
    test("constructor - without children", (){
      Props props = new Props();
      expect(props.children, isNull);
    });
    
    test("constructor - with children", (){
      var children = [new ComponentDescriptionMock()];
      Props props = new Props(children);
      expect(props.children, equals(children));
    });

    test("children setter", (){
      var children = [new ComponentDescriptionMock()];
      Props props = new Props();
      props.children = children;
      expect(props.children, equals(children));
    });
  });
}