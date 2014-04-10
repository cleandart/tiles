import 'common/mass.dart';
import 'utils/wrapper.dart';
import 'dart:html';

main() {
  initReact();
  mountComponent(mass(), querySelector("#container"));
}