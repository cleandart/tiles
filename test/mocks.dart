library tiles_test_mocks;

import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'dart:async';

class ComponentMock extends Mock implements Component {}

class NodeMock extends Mock implements Node {}

class ComponentDescriptionMock extends Mock implements ComponentDescription {}

class StreamControllerMock extends Mock implements StreamController {}
