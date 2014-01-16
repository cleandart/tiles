library tiles_component_test;
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:library/library.dart';
import 'mocks.dart';
import 'dart:async';

main() {
  
  group("(Component)", () {
    Props props, otherProps;
    Component component;
    
    /**
     * setup method, by default create new props, new otherProps and new component with props; 
     */
    setUp((){
      props = new PropsMock();
      otherProps = new PropsMock();
      component = new Component(props);
    });
    
    test("constructor", () {
      expect(component, isNotNull);
      expect(component.props, equals(props));
    });
    
    test("constructor with stream", (){
      StreamController controller = new StreamController();
      component = new Component(props, controller);
      
      expect(component.needUpdate, equals(controller.stream));
    });
    
    test("props setter change props", () {
      component.props = otherProps;
      
      expect(component.props, equals(otherProps));
    });
    
    test("shouldUpdate return by default true", () {
       expect(component.shouldUpdate(otherProps, props), isTrue);
    });
    
    test("needUpdate stream is stream", () {
      expect(component.needUpdate is Stream, isTrue);
    });
    
    test("needUpdate do not add nothing if redraw is not called", (){
      component.needUpdate.listen(expectAsync1((now){}, count: 0));
    });

    test("redraw create one event in needUpdate", (){
      bool needed = false;
      component.needUpdate.listen(expectAsync1((now){}, count: 1));
      component.redraw();
    });

    test("2 redraws -> 2 events in needUpdate", (){
      bool needed = false;
      component.needUpdate.listen(expectAsync1((now){}, count: 2));
      component.redraw();
      component.redraw();
    });
    
    test("redraw call needUpdateController add", () {
      StreamControllerMock controller = new StreamControllerMock();
      component = new Component(props, controller);
      
      component.redraw();
      
      controller.getLogs(callsTo("add")).verify(happenedOnce);
    });
    
    test("default redraw is not immediate", (){
      component.redraw();
      component.needUpdate.listen(expectAsync1((now){if(now == true) throw 0;}, count: 1));
    });
    
    test("immediate redraw add event with true argument", (){
      component.redraw(true);
      component.needUpdate.listen(expectAsync1((now){if(now != true) throw 0;}, count: 1));
    });

    
  });
  
}