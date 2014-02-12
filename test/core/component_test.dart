library tiles_component_test;
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import '../mocks.dart';
import 'dart:async';

main() {
  
  group("(Component)", () {
    dynamic props, otherProps;
    Component component;
    List<ComponentDescription> children;
    
    /**
     * setup method, by default create new props, new otherProps and new component with props; 
     */
    setUp(() {
      props = new Mock();
      otherProps = new Mock();
      component = new Component(props);
      children = [new ComponentDescriptionMock()];
    });
    
    test("constructor", () {
      expect(component, isNotNull);
      expect(component.props, equals(props));
    });
    
    test("constructor with stream", () {
      StreamController controller = new StreamController();
      component = new Component(props, null, controller);
      
      expect(component.needUpdate, equals(controller.stream));
    });
    
    test("constructor with children", () {
      component = new Component(null, children);
      
      expect(component.children, equals(children));
    });
    
    test("props setter change props", () {
      component.props = otherProps;
      
      expect(component.props, equals(otherProps));
    });
    
    test("should accept setted children", () {
      expect(component.children, isNull);
      
      component.children = children;
      
      expect(component.children, equals(children));
    });
    
    test("should accept removing children", () {
      component.children = children;
      expect(component.children, equals(children));
      
      component.children = null;
      
      expect(component.children, isNull);
    });
    
    test("shouldUpdate return by default true", () {
       expect(component.shouldUpdate(otherProps, props), isTrue);
    });
    
    test("needUpdate stream is stream", () {
      expect(component.needUpdate is Stream, isTrue);
    });
    
    test("needUpdate do not add nothing if redraw is not called", () {
      component.needUpdate.listen(expectAsync1((now) {}, count: 0));
    });

    test("redraw create one event in needUpdate", () {
      bool needed = false;
      component.needUpdate.listen(expectAsync1((now) {}, count: 1));
      component.redraw();
    });

    test("2 redraws -> 2 events in needUpdate", () {
      bool needed = false;
      component.needUpdate.listen(expectAsync1((now) {}, count: 2));
      component.redraw();
      component.redraw();
    });
    
    test("redraw call needUpdateController add", () {
      StreamControllerMock controller = new StreamControllerMock();
      component = new Component(props, null, controller);
      
      component.redraw();
      
      controller.getLogs(callsTo("add")).verify(happenedOnce);
    });
    
    test("default redraw is not immediate", () {
      component.redraw();
      component.needUpdate.listen(expectAsync1((now) {if (now == true) throw 0;}, count: 1));
    });
    
    test("immediate redraw add event with true argument", () {
      component.redraw(true);
      component.needUpdate.listen(expectAsync1((now) {if (now != true) throw 0;}, count: 1));
    });

    
  });
  
}
