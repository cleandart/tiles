library tiles_compoenent_description_test;

import 'package:unittest/unittest.dart';
import 'mocks.dart';
import 'package:library/library.dart';

main() {
  group("(ComponentDescription)", () {
    test("constructor (create with factory and args and then check if there is", (){
      
      Component component = new ComponentMock();
      ComponentFactory factory = ([args]) => null; 
      Props props = new PropsMock();
      
      ComponentDescription description = new ComponentDescription(factory, props);
      
      expect(description.factory, equals(factory));
      expect(description.props, equals(props));
    });

    test("createComponent", (){
      
      Component component = new ComponentMock();
      
      /**
       * flag, if factory was called
       */
      
      bool called = false;
      /**
       * factory allways return above component and set called to true
       */
      ComponentFactory factory = ([Props props]) {
        called = true;
        return component;
      }; 
      Props props = new PropsMock();
      
      ComponentDescription description = new ComponentDescription(factory, props);
      
      expect(description.createComponent(), equals(component));
      expect(called, isTrue);
    });
  });
}