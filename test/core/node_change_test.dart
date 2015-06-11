library tiles_node_change_test;

import 'package:unittest/unittest.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:math';
import 'package:mock/mock.dart';

main() {
  group("(NodeChange)", () {
    test("constructor", () {
      dynamic oldProps = new Mock();
      dynamic newProps = new Mock();
      Node node = new NodeMock();

      var rand = new Random();
      NodeChangeType type =
          NodeChangeType.values[rand.nextInt(NodeChangeType.values.length)];

      NodeChange change =
          new NodeChange(type, node, oldProps: oldProps, newProps: newProps);

      expect(change.type, equals(type));
      expect(change.node, equals(node));
      expect(change.oldProps, equals(oldProps));
      expect(change.newProps, equals(newProps));
    });
  });
}
