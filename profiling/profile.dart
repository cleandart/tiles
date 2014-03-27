library tiles_mount_component_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import 'dart:async';

Component _comp;

class Child extends Component {

  Child(props, [children]):super(props, children);

  didMount(){
    print('*************');
    print('Child didMount');
  }

  willReceiveProps(dynamic newProps){
    print('*************');
    print('Child willReceiveProps');
  }

  didUpdate() {
    print('*************');
    print('Child didUpdate');
  }

  render(){
    return [div({}, props['ch'])];
  }

}

ComponentDescriptionFactory child = registerComponent(
    ([dynamic props, dynamic children]) => new Child(props, children));

class Comp extends Component {

  var i=0;

  Comp(props, [children]):super(props, children){
    print('Comp constructor');
    _comp = this;
  }

  didMount(){
    print('*************');
    print('Comp didMount');
  }

  willReceiveProps(dynamic newProps){
    print('*************');
    print('Comp willReceiveProps');
  }

  didUpdate() {
    print('*************');
    print('Comp didUpdate');
  }

  render(){
    print('render');
//    i++;
    return [div({'class': 'myClass'}, [
               child({'ch': 'child1'}),
               child({'ch': 'child2'}),
//               div({'class': '$i'}, "$i"),
//               props['name'],
               ])
           ];
  }

}

ComponentDescriptionFactory comp = registerComponent(
    ([dynamic props, dynamic children]) => new Comp(props, children));

main() {
    initTilesBrowserConfiguration();

    mountComponent(comp({'name': 'jozo'},[]), querySelector('#main'));

    Node node = rootNodes[0];
    new Future.delayed(new Duration(seconds: 1), (){
      _comp.redraw();
    });

}