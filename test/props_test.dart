library tiles_props_test;

import 'package:unittest/unittest.dart';
import 'package:tiles/tiles.dart';
import 'mocks.dart';

main() {
  group("(Props)", () {
    test("constructor - without children", () {
      Props props = new Props();
      expect(props, isNotNull);
    });
    
  });
}
