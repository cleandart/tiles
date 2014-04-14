import 'common/mass.dart';
import 'utils/wrapper.dart';
import 'common/settings.dart';
import 'dart:html';

main() {
  initTiles();
  mountComponent(mass(props: settings["mass"]["props"]), querySelector("#mass_tiles"));
}