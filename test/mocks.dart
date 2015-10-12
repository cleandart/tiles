library tiles_test_mocks;

import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'dart:async';

class ComponentMock extends Mock implements Component {}

class NodeMock extends Mock implements Node {}

class ComponentDescriptionMock extends Mock implements ComponentDescription {}

class StreamControllerMock extends Mock implements StreamController {}

class CustomComponent extends Component {
  CustomComponent(props, children) : super(props, children);

  render() => children;
}

ComponentDescriptionFactory customComponent = registerComponent(
    ({props, children}) => new CustomComponent(props, children));
