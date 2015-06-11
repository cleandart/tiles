library selenium_application_test;

import 'package:webdriver/webdriver.dart';
import 'package:unittest/unittest.dart';
import '../test_utils.dart';

void main() {
//  useCompactVMConfiguration();
  WebElement button;
  WebElement text;

  String testApplicationPath = getTestPagePath("toggle", "toggle.html");

  setUp(() {
    return getWebDriver()
        .then((_driver) => driver = _driver)
        .then((_) => driver.get(testApplicationPath))
        .then((_) => driver.findElement(new By.id('toggle')))
        .then((_element) => button = _element)
        .then((_) => driver.findElement(new By.id('expandedLex')))
        .then((_element) => text = _element);
  });

  tearDown(closeWebDriver);

  group("webdriver", () {
    solo_seleniumTest('should have + and extended', () {
      expect(button, isNotNull);
      expect(text, isNotNull);
      return text.text.then(expectAsync((_text) {
        expect(_text, equals("expanded"));
      }));
    });

    solo_seleniumTest('change expanded to collapsed after click', () {
      return driver.mouse
          .moveTo(element: button)
          .click()
          .then((_) => sleep(100)) //because of animation frame
          .then((_) => driver.findElement(new By.id('collapsed')))
          .then((_element) => text = _element)
          .then((_) => text.text)
          .then((_text) {
        expect(_text, equals('collapsed'));
      });
    });

    solo_seleniumTest('change after 5 clicks there should be 1 collapsed', () {
      return driver.mouse.moveTo(element: button).click() // 1. click
          .then((_) => sleep(100))
          .then((_) => driver.mouse.moveTo(element: button).click()) // 2. click
          .then((_) => sleep(100))
          .then((_) => driver.mouse.moveTo(element: button).click()) // 3. click
          .then((_) => sleep(100))
          .then((_) => driver.mouse.moveTo(element: button).click()) // 4. click
          .then((_) => sleep(100))
          .then((_) => driver.mouse.moveTo(element: button).click()) // 5. click
          .then((_) => sleep(100))
          .then((_) => driver.findElement(new By.id('collapsed')))
          .then((_element) => text = _element)
          .then((_) => text.text)
          .then((_text) {
        expect(_text, equals('collapsed'));
      });
    });
  });
}
