import 'common/structure.dart';
import 'utils/wrapper.dart';
import 'common/settings.dart';
import 'dart:html';

main() {
  initTiles();
  mountComponent(structure(props: settings["structure"]["props"]), querySelector("#structure_tiles"));
}