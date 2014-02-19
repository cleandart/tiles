library tiles_test;

import 'browser/mount_component_test.dart' as mountComponent;
import 'browser/update_component_test.dart' as updateComponent;
import 'package:unittest/html_individual_config.dart';

main () {
  useHtmlIndividualConfiguration();
  mountComponent.main();
  updateComponent.main();
}
