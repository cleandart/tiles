import 'common/mass.dart';
import 'utils/wrapper.dart';
import 'dart:html';

main() {
  initTiles();
  mountComponent(mass(), querySelector("#container"));
}