library tiles_test_mocks;

import 'package:unittest/mock.dart';
import 'package:library/library.dart';
import 'dart:async';

class ComponentMock extends Mock implements Component {}

class PropsMock extends Mock implements Props {}

class NodeMock extends Mock implements Node {}

class ComponentDescriptionMock extends Mock implements ComponentDescription {}

class StreamControllerMock extends Mock implements StreamController {}
