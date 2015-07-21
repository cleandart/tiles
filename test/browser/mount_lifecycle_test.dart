library tiles_mount_lifecycle_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import 'dart:async';
import '../mocks.dart';

main() {
  group("(browser) (LifeCycle)", () {
    
    Element mountRoot;

    ComponentDescriptionMock description;
    ComponentMock component;
    StreamController controller;

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
      when(component.render).thenReturn(null);
      when(component.shouldUpdate).thenReturn(true);

      description = new ComponentDescriptionMock();
      when(description.createComponent()).thenReturn(component);

      controller = new StreamController();
      when(component.needUpdate).thenReturn(controller.stream);

      querySelector("body").append(mountRoot);
    });

    test("should call didMount after mount", () {
      mountComponent(description, mountRoot);
      verify(component.render());
      verify(component.didMount());
    });

    test(
        "should call shouldUpdate, render and didUpdate when node is marked as dirty",
        () {
      mountComponent(description, mountRoot);

      clearInteractions(component);
      controller.add(null);

      window.animationFrame.then(expectAsync((val) {
        verifyNever(component.willReceiveProps(any));
        verify(component.shouldUpdate(any, any));
        verify(component.render());

        verify(component.didUpdate());
      }));
    });

    test("should call willUnmount when it is unmounted", () {
      mountComponent(description, mountRoot);

      clearInteractions(component);
      unmountComponent(mountRoot);

      verify(component.willUnmount());
      
      verifyNever(component.shouldUpdate(any, any));
      verifyNever(component.willReceiveProps(any));
      verifyNever(component.render());
      verifyNever(component.didUpdate());
    });

    group("(core complex)", () {
      Map<dynamic, StreamController> controllers;
      ComponentMock c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
      ComponentDescriptionMock dc1,
          dc2,
          dc3,
          dc4,
          dc5,
          dc6,
          dc7,
          dc8,
          dc9,
          dc10,
          dc11;

      createDefaultDescription(ComponentMock component) {
        ComponentDescriptionMock description = new ComponentDescriptionMock();
        when(description.createComponent()).thenReturn(component);
        return description;
      }

      createCleanComponent() {
        ComponentMock component = new ComponentMock();

        StreamController controller = new StreamController(sync: true);
        when(component.needUpdate).thenReturn(controller.stream);

        controllers[component] = controller;

        return component;
      }

      createDefaultComponent([List<ComponentDescriptionMock> whatToRender]) {
        ComponentMock component = createCleanComponent();

        when(component.shouldUpdate(any, any)).thenReturn(true);

        when(component.render()).thenReturn(whatToRender);

        return component;
      }

      resetAll() {
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

      const String ONCE = "ONCE";
      const String NEVER = "NEVER";
      shouldHappened(Iterable<ComponentMock> components, String what, String expect) {
        for (component in components) {
          var verif = expect == ONCE ? verify : verifyNever;
          switch (what) {
            case "render":
              verif(component.render());
              break;
            case "didUpdate":
              verif(component.didUpdate());
              break;
            case "didMount":
              verif(component.didMount());
              break;
            case "willUnmount":
              verif(component.willUnmount());
              break;
          }
        }
      }

      shouldHappenedOncee(String what) {
        shouldHappened(
            [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11].reversed, what, ONCE);
      }
      shouldNeverHappenedd(String what) {
        shouldHappened(
            [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11], what, NEVER);
      }

      createStructure() {
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
        c11 = createDefaultComponent();
        named(c11, name: "c11");
        c10 = createDefaultComponent();
        named(c10, name: "c10");
        c9 = createDefaultComponent();
        named(c9, name: "c9");
        c8 = createDefaultComponent();
        named(c8, name: "c8");
        c7 = createDefaultComponent();
        named(c7, name: "c7");

        dc7 = createDefaultDescription(c7);
        dc8 = createDefaultDescription(c8);
        dc9 = createDefaultDescription(c9);
        dc10 = createDefaultDescription(c10);
        dc11 = createDefaultDescription(c11);

        c6 = createDefaultComponent([dc10, dc11]);
        named(c6, name: "c6");
        c5 = createDefaultComponent([dc8, dc9]);
        named(c5, name: "c5");
        c4 = createDefaultComponent([dc7]);
        named(c4, name: "c4");

        dc4 = createDefaultDescription(c4);
        dc5 = createDefaultDescription(c5);
        dc6 = createDefaultDescription(c6);

        c3 = createDefaultComponent([dc6]);
        named(c3, name: "c3");
        c2 = createDefaultComponent([dc4, dc5]);
        named(c2, name: "c2");
        dc2 = createDefaultDescription(c2);
        dc3 = createDefaultDescription(c3);

        c1 = createDefaultComponent([dc2, dc3]);
        named(c1, name: "c1");
        dc1 = createDefaultDescription(c1);
        
      }

      setUp(() {
        controllers = {};
        createStructure();
        mountComponent(dc1, mountRoot);
      });
      
      test("should be every render called once in more complex structure", () {
        shouldHappenedOncee("render");
      });

      test("should call didMount on every component", () {
        shouldHappenedOncee("didMount");
      });

      test("should call didUpdate for every updated node", () {
        controllers[c1].add(true);
        resetAll();
        window.animationFrame.then(expectAsync((data) {
            shouldHappenedOncee("didUpdate");
        }));
      });

      test("shold call didUpdate only under dirty node", () {
        resetAll();

        controllers[c2].add(true);
        window.animationFrame.then(expectAsync((data) {
          shouldHappened([c1, c3, c6, c10, c11], "didUpdate", NEVER);
          shouldHappened([c2, c4, c5, c7, c8, c9], "didUpdate", ONCE);
        }));
      });

      test("should unmount everything on unmountComponent", () {
        unmountComponent(mountRoot);

        shouldHappened([
          c1,
          c2,
          c3,
          c4,
          c5,
          c6,
          c7,
          c8,
          c9,
          c10,
          c11
        ], "willUnmount", ONCE);
      });

      test("should unmount whole subtree when one component remove child", () {
        unmountComponent(mountRoot);

        createStructure();
        c1 = createCleanComponent();
        when(c1.shouldUpdate(any, any)).thenReturn(true);
        when(c1.render()).thenReturn([dc2, dc3]).thenReturn([dc2]);
        dc1 = createDefaultDescription(c1);
        mountComponent(dc1, mountRoot);
        
        when(c1.render()).thenReturn([dc2]);

        shouldHappenedOncee("render");
        resetAll();

        controllers[c1].add(true);
        window.animationFrame.then(expectAsync((data) {
          var stilMounted = [c1, c2, c4, c5, c7, c8, c9];
          var unmounted = [c3, c6, c10, c11];
          shouldHappened(stilMounted, "didUpdate", ONCE);
          shouldHappened(unmounted, "didUpdate", NEVER);
          shouldHappened(stilMounted, "willUnmount", NEVER);
          shouldHappened(unmounted, "willUnmount", ONCE);
        }));
      });
      test("should didMount new whole subtree when one component add child child",() {
        unmountComponent(mountRoot);

        createStructure();
        var controller = controllers[c1];
        
        c1 = createCleanComponent();
        when(c1.shouldUpdate(any, any)).thenReturn(true);
        when(c1.render()).thenReturn([dc2]);
        when(c1.needUpdate).thenReturn(controller.stream);
        
        dc1 = createDefaultDescription(c1);
        
        mountComponent(dc1, mountRoot);

        when(c1.render()).thenReturn([dc2, dc3]);
        resetAll();
        controller.add(true);

        window.animationFrame.then(expectAsync((data) {
          var stilMounted = [c1, c2, c4, c5, c7, c8, c9];
          var mounted = [c3, c6, c10, c11];
          shouldHappened(stilMounted, "didUpdate", ONCE);
          shouldHappened(mounted, "didUpdate", NEVER);
          shouldHappened(stilMounted, "didMount", NEVER);
          shouldHappened(mounted, "didMount", ONCE);
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
