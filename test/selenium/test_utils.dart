library webdriver_test_util;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';
import 'package:webdriver/webdriver.dart';

WebDriver driver;

int _counter = 0;
int _soloCounter = 0;

Future<WebDriver> getWebDriver() {
  if (driver != null) {
    return new Future(() => driver);
  } else {
    return WebDriver.createDriver(desiredCapabilities: Capabilities.chrome);
  }
}

void seleniumTest(String name, Function testFunction) {
  ++_counter;
  return test(name, testFunction);
}

void solo_seleniumTest(String name, Function testFunction) {
  ++_soloCounter;
  return solo_test(name, testFunction);
}

void closeWebDriver() {
  if (_soloCounter > 0) {
    if (--_soloCounter == 0) {
      driver.close();
    }
  } else {
    if (--_counter == 0) {
      driver.close();
    }
  }
}

String getTestPagePath(String directory, String application) {
  var currentPath = path.current;
  var testPath = "test";
  var seleniumTestPath = "selenium";
  if (currentPath.contains(directory)) {
    directory = "";
  }
  if (currentPath.contains(testPath)) {
    testPath = "";
  }
  if (currentPath.contains(seleniumTestPath)) {
    seleniumTestPath = "";
  }
  var testPagePath = path.join(
      currentPath, testPath, seleniumTestPath, directory, application);
  testPagePath = path.absolute(testPagePath);
  if (!FileSystemEntity.isFileSync(testPagePath)) {
    throw new Exception('Could not find the test file at "$testPagePath".'
        ' Make sure you are running tests from the root of the project.');
  }
  return path.toUri(testPagePath).toString();
}

Future sleep(int miliseconds, [dynamic result]) {
  Completer completer = new Completer();
  Duration duration = new Duration(milliseconds: miliseconds);
  Timer timer = new Timer(duration, () => completer.complete(result));
  return completer.future;
}
