import 'common/structure.dart';
import 'utils/wrapper.dart';
import 'common/settings.dart';
import 'dart:html';

main() {
  initReact();
  mountComponent(structure(props: settings["structure"]["props"]), querySelector("#structure_react"));
}