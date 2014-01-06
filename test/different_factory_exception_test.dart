import 'package:unittest/unittest.dart';
import 'package:library/library.dart';

main() {
  group("(DifferentFactoryException)", () {
    
    test("constructor", () {
      DifferentFactoryException ex = new DifferentFactoryException("message");
      expect(ex.msg, equals("message"));
      expect(ex.toString(), equals("DifferentFactoryException:message"));
    });

    test("throw-catch", () {
      
      /** with message */
      try {
        throw new DifferentFactoryException("message");
      } catch (ex) {
        expect(ex.msg, equals("message"));
        expect(ex.toString(), equals("DifferentFactoryException:message"));
      }
      
      /** without message */
      try {
        throw new DifferentFactoryException();
      } catch (ex) {
        expect(ex.msg, isNull);
        expect(ex.toString(), equals("DifferentFactoryException"));
      }
    });
  });
}

