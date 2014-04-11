library tiles_mount_lifecycle_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import 'dart:async';
import '../mocks.dart';

main() {
  group("(browser) (LifeCycle)", () {
    Element mountRoot;

    ComponentDescriptionMock description;
    ComponentMock component;

    try {
      initTilesBrowserConfiguration();
    } catch (e) {}

    setUp(() {
      /**
       * create new mountRoot
       */
      mountRoot = new Element.div();

      /**
       * Prepare descriptions
       */

      component = new ComponentMock();
      component.when(callsTo("render")).alwaysReturn(null);
      component.when(callsTo("shouldUpdate")).alwaysReturn(true);

      description = new ComponentDescriptionMock();
      description.when(callsTo("createComponent")).alwaysReturn(component);

      StreamController controller = new StreamController();
      component.when(callsTo("get needUpdate"))
        .alwaysReturn(controller.stream);

      component.when(callsTo("redraw"))
        .alwaysCall(([bool what]) => controller.add(what));

      querySelector("body").append(mountRoot);
    });

    test("should call didMount after mount", () {
      mountComponent(description, mountRoot);
      component.getLogs(callsTo("render")).verify(happenedOnce);
      component.getLogs(callsTo("didMount")).verify(happenedOnce);
    });

    test("should call shouldUpdate, render and didUpdate when node is marked as dirty", () {
      mountComponent(description, mountRoot);

      component.redraw();
      component.clearLogs();

      window.animationFrame.then(expectAsync((val) {
        component.getLogs(callsTo("shouldUpdate")).verify(happenedOnce);

        component.getLogs(callsTo("willReceiveProps")).verify(neverHappened);
        component.getLogs(callsTo("render")).verify(happenedOnce);

        component.getLogs(callsTo("didUpdate")).verify(happenedOnce);
      }));
    });

    test("should call willUnmount when it is unmounted", () {
      mountComponent(description, mountRoot);

      component.clearLogs();
      unmountComponent(mountRoot);

      component.getLogs(callsTo("shouldUpdate")).verify(neverHappened);
      component.getLogs(callsTo("willReceiveProps")).verify(neverHappened);
      component.getLogs(callsTo("render")).verify(neverHappened);
      component.getLogs(callsTo("didUpdate")).verify(neverHappened);

      component.getLogs(callsTo("willUnmount")).verify(happenedOnce);
    });

    group("(core complex)", () {
      ComponentMock c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
      ComponentDescriptionMock dc1, dc2, dc3, dc4, dc5, dc6, dc7, dc8, dc9, dc10, dc11;

      createDefaultDescription (ComponentMock component) {
        ComponentDescriptionMock description = new ComponentDescriptionMock();
        description.when(callsTo("createComponent")).alwaysReturn(component);
        return description;
      }

      createCleanComponent () {
        ComponentMock component = new ComponentMock();

        StreamController controller = new StreamController();
        component.when(callsTo("get needUpdate"))
          .alwaysReturn(controller.stream);

        component.when(callsTo("redraw"))
          .alwaysCall(([bool what]) => controller.add(what));

        return component;
      }

      createDefaultComponent ([List<ComponentDescriptionMock> whatToRender]) {
        ComponentMock component = createCleanComponent();

        component.when(callsTo("shouldUpdate")).alwaysReturn(true);

        component.when(callsTo("render")).alwaysReturn(whatToRender);

        return component;
      }

      clearLogs() {
        c1.clearLogs();
        c2.clearLogs();
        c3.clearLogs();
        c4.clearLogs();
        c5.clearLogs();
        c6.clearLogs();
        c7.clearLogs();
        c8.clearLogs();
        c9.clearLogs();
        c10.clearLogs();
        c11.clearLogs();
      }

      shouldHappened(List<ComponentMock> components, String what, expect) {
        for (component in components) {
          component.getLogs(callsTo(what)).verify(expect);
        }
      }

      shouldHappenedOnce(String what) {
        shouldHappened([c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], what, happenedOnce);
      }
      shouldNeverHappened(String what) {
        shouldHappened([c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], what, neverHappened);
      }

      createStructure () {
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
        dc1 = createDefaultDescription(c1);
      }

      setup() {
        createStructure();
        mountComponent(dc1, mountRoot);

      }
      setUp(setup);


      test("should be every render called once in more complex structure", () {
        shouldHappenedOnce("render");
      });

      test("should call didMount on every component", () {
        shouldHappenedOnce("didMount");
      });

      test("should call didUpdate for every updated node", () {
        clearLogs();
        c1.redraw();
        window.animationFrame.then(expectAsync((data) {
          shouldHappenedOnce("didUpdate");
        }));
      });

      test("shold call didUpdate only under dirty node", () {
        clearLogs();

        c2.redraw();
        window.animationFrame.then(expectAsync((data) {
          shouldHappened([c1, c3, c6, c10, c11], "didUpdate", neverHappened);
          shouldHappened([c2, c4, c5, c7, c8, c9], "didUpdate", happenedOnce);
        }));
      });

      test("should unmount everything on unmountComponent", () {
        unmountComponent(mountRoot);

        shouldHappened([c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], "willUnmount", happenedOnce);

      });

      test("should unmount whole subtree when one component remove child", () {
        unmountComponent(mountRoot);

        createStructure();
        c1 = createCleanComponent();
        c1.when(callsTo("shouldUpdate")).alwaysReturn(true);
        c1.when(callsTo("render"))
          .thenReturn([dc2, dc3])
          .thenReturn([dc2]);
        dc1 = createDefaultDescription(c1);
        mountComponent(dc1, mountRoot);

        shouldHappenedOnce("render");
        clearLogs();

        c1.redraw();

        window.animationFrame.then(expectAsync((data) {
          var stilMounted = [c1, c2, c4, c5, c7, c8, c9];
          var unmounted = [c3, c6,c10, c11];
          shouldHappened(stilMounted, "didUpdate", happenedOnce);
          shouldHappened(unmounted, "didUpdate", neverHappened);
          shouldHappened(stilMounted, "willUnmount", neverHappened);
          shouldHappened(unmounted, "willUnmount", happenedOnce);
        }));

      });
      test("should didMount new whole subtree when one component add child child", () {
        unmountComponent(mountRoot);

        createStructure();
        c1 = createCleanComponent();
        c1.when(callsTo("shouldUpdate")).alwaysReturn(true);
        c1.when(callsTo("render"))
          .thenReturn([dc2])
          .thenReturn([dc2, dc3]);
        dc1 = createDefaultDescription(c1);
        mountComponent(dc1, mountRoot);

        clearLogs();

        c1.redraw();

        window.animationFrame.then(expectAsync((data) {
          var stilMounted = [c1, c2, c4, c5, c7, c8, c9];
          var mounted = [c3, c6,c10, c11];
          shouldHappened(stilMounted, "didUpdate", happenedOnce);
          shouldHappened(mounted, "didUpdate", neverHappened);
          shouldHappened(stilMounted, "didMount", neverHappened);
          shouldHappened(mounted, "didMount", happenedOnce);
        }));

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
