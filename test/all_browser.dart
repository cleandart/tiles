library tiles_test;

import 'browser/mount_component_test.dart' as mountComponent;
import 'browser/mount_lifecycle_test.dart' as mountLifecycle;
import 'browser/update_component_test.dart' as updateComponent;
import 'browser/events_test.dart' as events;
import 'browser/keys_test.dart' as keys;
import 'package:unittest/html_individual_config.dart';

main () {
  useHtmlIndividualConfiguration();
  mountComponent.main();
  mountLifecycle.main();
  updateComponent.main();
  events.main();
  keys.main();
}
