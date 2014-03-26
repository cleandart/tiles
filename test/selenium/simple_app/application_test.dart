library selenium_application_test;

import 'package:webdriver/webdriver.dart';
import 'package:unittest/unittest.dart';
import '../test_utils.dart';

void main() {
//  useCompactVMConfiguration();
  WebElement textInput;
  WebElement label;
  
  String testApplicationPath = getTestPagePath("simple_app", "application.html");
  
  setUp(() {
    return getWebDriver()
        .then((_driver) => driver = _driver)
        .then((_) => driver.get(testApplicationPath))
        .then((_) =>
            driver.findElement(new By.cssSelector('input[type=text]')))
        .then((_element) => textInput = _element)
        .then((_) =>
            driver.findElement(new By.cssSelector('label')))
        .then((_element) => label = _element)
        .then((_) => driver.mouse.moveTo(element: textInput).click());
  });


  tearDown(closeWebDriver);
  
  group("webdriver", () {
    seleniumTest('should be possible to write to input', () {
      return driver.keyboard.sendKeys('abcdef')
          .then((_) => sleep(100)) //because of animation frame
          .then((_) => textInput.attributes['value'])
          .then((value) {
            expect(value, 'abcdef');
          });
    });
  
    seleniumTest('should fill span with value from input', () {
      return driver.keyboard.sendKeys('abcdef')
          .then((_) => sleep(100)) //because of animation frame
          .then((_) => label.text)
          .then((text) {
            expect(text, 'abcdef');
          });
    });

    seleniumTest('should fill span with value from input writed by one char', () {
      return driver.keyboard.sendKeys(['a', 'b', 'c', 'd', 'e', 'f'])
          .then((_) => sleep(100)) //because of animation frame
          .then((_) => label.text)
          .then((text) {
            expect(text, 'abcdef');
          });
    });
    seleniumTest('should fill span with value from input with cursor move', () {
      return driver.keyboard.sendKeys(['a', 'e', 'f', Keys.LEFT, Keys.LEFT, 'b', 'c', 'd'])
          .then((_) => sleep(100)) //because of animation frame
          .then((_) => label.text)
          .then((text) {
            expect(text, 'abcdef');
          });
    });
    
    seleniumTest('should empty span on click on span', () {
      return driver.keyboard.sendKeys(['a', 'e', 'f', Keys.LEFT, Keys.LEFT, 'b', 'c', 'd'])
          .then((_) => driver.mouse.moveTo(element: label).click())
          .then((_) => sleep(100))
          .then((_) => label.text)
          .then((text) {
            expect(text, "");
          })
          .then((_) => textInput.attributes["value"])
          .then((value) {
            expect(value, "abcdef");
          });
    });
  });
}
