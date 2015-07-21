library tiles_lifecycle_test;
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';

main() {
  group("(LifeCycle)", () {
    Component component;
    Node node;

    setUp(() {
      component = new ComponentMock();
      when(component.shouldUpdate(any, any)).thenReturn(true);

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

        verify(component.render());
      });
    });

    group("(willReceiveProps)", () {
      test("should call willReceiveProps once on node apply", () {
        node.apply();

        verify(component.willReceiveProps(any)).called(1);
      });
    });

    group("(shouldUpdate)", () {
      test("should not call shouldUpdate on first update", () {
        verifyNever(component.shouldUpdate(any, any));
      });

      test("should call shouldUpdate once on node not first update", () {
        updateNode();
        verify(component.shouldUpdate(any, any));
      });

      test("should not call render, if shouldUpdate return false", () {
        eraseComponent();

        when(component.shouldUpdate(any, any)).thenReturn(false);
        reset(component);

        updateNode();

        verify(component.render());
      });

      test("should receive correct old and next props in shouldUpdate", () {
        component = spy(new ComponentMock(), new Component(null));

        node = new Node(null, component, null);
        node.update();



        /**
         * apply props
         */
        node.apply(props: "oldProps");
        node.apply(props: "nextProps");

        /**
         * expect called of shouldUpdate with correct values
         */
        when(component.shouldUpdate(any, any)).thenAnswer(expectAsync((Invocation inv) {
            var oldProps = inv.positionalArguments[1];
            var nextProps = inv.positionalArguments[0]; 
            expect(oldProps, equals("oldProps"));
            expect(nextProps, equals("nextProps"));
            return true;
          }));

        updateNode();
      });
    });

    group("(core complex)", () {
      ComponentMock c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
      ComponentDescriptionMock dc1, dc2, dc3, dc4, dc5, dc6, dc7, dc8, dc9, dc10, dc11;
      Node n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11;

      createDefaultDescription (ComponentMock component) {
        ComponentDescriptionMock description = new ComponentDescriptionMock();
        when(description.createComponent()).thenReturn(component);
        return description;
      }
      createDefaultComponent ([List<ComponentDescription> whatToRender]) {
        ComponentMock component = new ComponentMock();
        when(component.shouldUpdate(any, any)).thenReturn(true);
        when(component.render()).thenReturn(whatToRender);
        return component;
      }

      clearLogs() {
        clearInteractions(c1);
        clearInteractions(c2);
        clearInteractions(c3);
        clearInteractions(c4);
        clearInteractions(c5);
        clearInteractions(c6);
        clearInteractions(c7);
        clearInteractions(c8);
        clearInteractions(c9);
        clearInteractions(c10);
        clearInteractions(c11);
      }

      var ONCE = "ONCE";
      var NEVER = "NEVER";
      
      shouldHappened(List<ComponentMock> components, String what, expect) {
        for (component in components) {
          var verif;
          if(expect == NEVER) {
            verif = verifyNever;
          }
          if (expect == ONCE) {
            verif = verify;
          }
          
          var whatt;
          if(what == "render") whatt = component.render(); 
          if(what == "shouldUpdate") whatt = component.shouldUpdate(any, any);
          if(what == "willReceiveProps") whatt = component.willReceiveProps(any);
                    
          verif(whatt);
        }
      }

      shouldHappenedOnce(String what) {
        shouldHappened([c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], what, ONCE);
      }
      shouldNeverHappened(String what) {
        shouldHappened([c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], what, NEVER);
      }

      setUp(() {
        /**
         * Structure
         *            c1
         *           /  \
         *         c2    c3
         *        /  \     \
         *      c4    c5    \___c6
         *     /     /  \      /  \
         *   c7     c8   c9   c10  c11
         */
        c7 = createDefaultComponent();
        c8 = createDefaultComponent();
        c9 = createDefaultComponent();
        c10 = createDefaultComponent();
        c11 = createDefaultComponent();

        dc7 = createDefaultDescription(c7);
        dc8 = createDefaultDescription(c8);
        dc9 = createDefaultDescription(c9);
        dc10 = createDefaultDescription(c10);
        dc11 = createDefaultDescription(c11);

        c4 = createDefaultComponent([dc7]);
        c5 = createDefaultComponent([dc8, dc9]);
        c6 = createDefaultComponent([dc10, dc11]);

        dc4 = createDefaultDescription(c4);
        dc5 = createDefaultDescription(c5);
        dc6 = createDefaultDescription(c6);

        c2 = createDefaultComponent([dc4, dc5]);
        c3 = createDefaultComponent([dc6]);
        dc2 = createDefaultDescription(c2);
        dc3 = createDefaultDescription(c3);

        c1 = createDefaultComponent([dc2, dc3]);

        node = new Node(null, c1, null);
        node.update();

        n1 = node;
        n2 = node.children.first;
        n3 = node.children.last;
        n4 = node.children.first.children.first;
        n5 = node.children.first.children.last;
        n6 = node.children.last.children.first;
        n7 = node.children.first.children.first.children.first;
        n8 = node.children.first.children.last.children.first;
        n9 = node.children.first.children.last.children.last;
        n10 = node.children.last.children.last.children.first;
        n11 = node.children.last.children.last.children.last;
      });

      test("should have correct structure with more complex descriptions", () {
        expect(n1.children.length, equals(2));
        expect(n1.component, equals(c1));

        expect(n2.children.length, equals(2));
        expect(n2.component, equals(c2));

        expect(n3.children.length, equals(1));
        expect(n3.component, equals(c3));

        expect(n4.children.length, equals(1));
        expect(n4.component, equals(c4));

        expect(n5.children.length, equals(2));
        expect(n5.component, equals(c5));

        expect(n6.children.length, equals(2));
        expect(n6.component, equals(c6));

        expect(n7.children.length, equals(0));
        expect(n7.component, equals(c7));

        expect(n8.children.length, equals(0));
        expect(n8.component, equals(c8));

        expect(n9.children.length, equals(0));
        expect(n9.component, equals(c9));

        expect(n10.children.length, equals(0));
        expect(n10.component, equals(c10));

        expect(n11.children.length, equals(0));
        expect(n11.component, equals(c11));

      });

      test("should be every render called once in more complex structure", () {
        shouldHappenedOnce("render");
      });

      test("should no render be called if nothing is dirty", () {
        clearLogs();
        node.update();
        shouldNeverHappened("render");
      });

      test("should call shouldUpdate for every updated node", () {
        clearLogs();
        node.isDirty = true;
        node.update();
        shouldHappenedOnce("shouldUpdate");
      });

      test("shold call shouldupdate only under dirty node", () {
        clearLogs();

        n2.isDirty = true;
        node.update();
        shouldHappened([c1, c3, c6, c10, c11], "render", NEVER);
        shouldHappened([c2, c4, c5, c7, c8, c9], "render", ONCE);
      });
      test("shold call willReceiveProps on correct places", () {
        clearLogs();

        n2.isDirty = true;
        node.update();
        shouldHappened([c1, c2, c3, c6, c10, c11], "willReceiveProps", NEVER);
        shouldHappened([c4, c5, c7, c8, c9], "willReceiveProps", ONCE);
      });

      test("shold call render, shouldUpdate and willReceiveProps on correct places, when 2 nodes are dirty in one route from root to leaf", () {
        clearLogs();

        n2.isDirty = true;
        n4.isDirty = true;
        node.update();
        shouldHappened([c1, c3, c6, c10, c11], "render", NEVER);
        shouldHappened([c2, c4, c5, c7, c8, c9], "render", ONCE);

        shouldHappened([c1, c3, c6, c10, c11], "shouldUpdate", NEVER);
        shouldHappened([c2, c4, c5, c7, c8, c9], "shouldUpdate", ONCE);

        shouldHappened([c1, c2, c3, c6, c10, c11], "willReceiveProps", NEVER);
        shouldHappened([c4, c5, c7, c8, c9], "willReceiveProps", ONCE);
      });

      test("should do nothing, if there was nothing dirty, after more times, when something was dirty", () {
        node.isDirty = true;
        node.update();
        n2.isDirty = true;
        node.update();
        n4.isDirty = true;
        node.update();
        n3.isDirty = true;
        node.update();
        clearLogs();
        node.update();
        shouldNeverHappened("render");
        shouldNeverHappened("shouldUpdate");
        shouldNeverHappened("willReceiveProps");
      });
      /**
       * Structure
       *            c1
       *           /  \
       *         c2    c3
       *        /  \     \
       *      c4    c5    \___c6
       *     /     /  \      /  \
       *   c7     c8   c9   c10  c11
       */


    });

  });
}

