import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:library/library.dart';
import 'dart:math';

class PropsMock extends Mock implements Props {}
class NodeMock extends Mock implements Node {}

main() {
  
  group("(NodeChange)", (){
    test("constructor", (){
      Props oldProps = new PropsMock();
      Props newProps = new PropsMock();
      Node node = new NodeMock();

      var rand = new Random();
      NodeChangeType type = NodeChangeType.values[rand.nextInt(NodeChangeType.values.length)];
      
      NodeChange change = new NodeChange(type, node, oldProps, newProps);
      
      expect(change.type, equals(type));
      expect(change.node, equals(node));
      expect(change.oldProps, equals(oldProps));
      expect(change.newProps, equals(newProps));
    });
  });
}