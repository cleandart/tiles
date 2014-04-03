library tiles_lifecycle_test;
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:async';

main() {
  group("(LifeCycle)", () {
    ComponentMock component;
    Node node;

    setUp(() {
      component = new ComponentMock();
      component.when(callsTo("shouldUpdate")).alwaysReturn(true);

      node = new Node(null, component, null);
      node.update();

    });

    eraseComponent() {
      component = new ComponentMock();

      node = new Node(null, component, null);
      node.update();

    }

    updateNode() {
      node.isDirty = true;
      node.update();
    }

    group("(render)", () {
      test("should call render once on create and update node", () {

        component.getLogs(callsTo("render")).verify(happenedExactly(1));
      });
    });

    group("(willReceiveProps)", () {
      test("should call willReceiveProps once on node apply", () {
        node.apply();

        component.getLogs(callsTo("willReceiveProps")).verify(happenedExactly(1));
      });
    });

    group("(shouldUpdate)", () {
      test("should not call shouldUpdate on first update", () {
        component.getLogs(callsTo("shouldUpdate")).verify(neverHappened);
      });

      test("should call shouldUpdate once on node not first update", () {
        updateNode();
        component.getLogs(callsTo("shouldUpdate")).verify(happenedExactly(1));
      });

      test("should not call render, if shouldUpdate return false", () {
        eraseComponent();

        component.when(callsTo("shouldUpdate")).alwaysReturn(false);
        component.clearLogs();

        updateNode();

        component.getLogs(callsTo("render")).verify(neverHappened);
      });

      test("should receive correct old and next props in shouldUpdate", () {
        eraseComponent();

        /**
         * fake props functionality
         */
        var props;
        component.when(callsTo("set props")).alwaysCall((_props) => props = _props);
        component.when(callsTo("get props")).alwaysCall(() => props);

        /**
         * apply props
         */
        node.apply("oldProps");
        node.apply("nextProps");

        /**
         * expect called of shouldUpdate with correct values
         */
        component.when(callsTo("shouldUpdate")).thenCall(expectAsync((nextProps, oldProps) {
            expect(oldProps, equals("oldProps"));
            expect(nextProps, equals("nextProps"));
            return true;
          }));

        updateNode();
      });
    });

  });
}

