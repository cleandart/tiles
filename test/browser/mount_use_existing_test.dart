library tiles_mount_useExisting_test;

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';
import 'dart:html';
import '../mocks.dart';

main() {
  group("(useExisting)", () {
    Element mountRoot;
    String imageSource =
        "http://github.global.ssl.fastly.net/images/modules/logos_page/GitHub-Mark.png";

    Element spann;
    Element spann_div;
    Element spann_span;
    Element spann_div_span;
    
    ComponentDescription defaultDescription = span(children: [
      customComponent(children: div(children: span(props: {"class": "classs"}))),
      span()
    ]);

    try {
      initTilesBrowserConfiguration();
    } catch (e) {}

    setUp(() {
      /**
       * create new mountRoot
       */
      mountRoot = new Element.div();

      /**
       * Prepare descriptions
       */

      /**
       * uncomment to see what theese test do in browser
       */
      querySelector("body").append(mountRoot);

      spann = new SpanElement();
      spann_div = new DivElement();
      spann_span = new SpanElement();
      spann_div_span = new SpanElement();

      spann.children.add(spann_div);
      spann.children.add(spann_span);
      spann_div.children.add(spann_div_span);

      mountRoot.children.add(spann);
    });
    
    verifyStructure() {
      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.firstChild, equals(spann));

      expect(spann.childNodes.length, equals(2));
      expect(spann.childNodes.first, equals(spann_div));
      expect(spann.childNodes.last, equals(spann_span));

      expect(spann_div.childNodes.length, equals(1));
      expect(spann_div.childNodes.first, equals(spann_div_span));
    }

    test("should use one-element structure", () {
      mountRoot.children..clear()..add(spann_span);

      mountComponent(span(), mountRoot, useExisting: true, clearNotUsed: false);

      expect(mountRoot.children.length, equals(1));
      expect(mountRoot.firstChild, equals(spann_span));
    });
    
    test("should use deeper structure", () {
      mountComponent(span(children: [
        div(children: span()),
        span()
      ]), mountRoot, useExisting: true, clearNotUsed: false);

      verifyStructure();
    });
    
    test("should clear not used by default", () {
      mountComponent(defaultDescription, mountRoot, useExisting: true);

      verifyStructure();
    });

    test("should clear also deeper structure", () {
      spann_div.children.add(new ImageElement());
      
      mountComponent(defaultDescription, mountRoot, useExisting: true);

      verifyStructure();
    });

    test("should not clear not used if set", () {
      mountRoot.children.add(new DivElement());
      mountComponent(defaultDescription, mountRoot, useExisting: true, clearNotUsed: false);

      expect(mountRoot.children.length, equals(2));
      expect(mountRoot.children.last is DivElement, isTrue);
    });

    test("should put inserted before", () {
      mountRoot.children.clear();
      mountRoot.children.add(new DivElement());
      mountComponent(defaultDescription, mountRoot, useExisting: true, clearNotUsed: false);

      expect(mountRoot.children.length, equals(2));
      expect(mountRoot.children.last is DivElement, isTrue);
    });

    test("should useExisting by default", () {
      mountComponent(defaultDescription, mountRoot);

      verifyStructure();
    });
    
    group("(attributes)", () {
      test("should set up props", () {
        mountComponent(defaultDescription, mountRoot, useExisting: true, clearNotUsed: false);

        verifyStructure();
        expect(spann_div_span.attributes["class"], equals("classs"));
      });
      
      test("should not remove not used attributes", () {
        spann_span.attributes["class"] = "should not change";
        mountComponent(defaultDescription, mountRoot, clearNotUsedAttributes: false);

        expect(spann_span.attributes["class"], equals("should not change"));
      });
      
      test("should clean not used attributes by default", () {
        spann_span.attributes["class"] = "should be removed";
        mountComponent(defaultDescription, mountRoot, useExisting: true);
        expect(spann_span.attributes["class"], isNull);
      });

      test("should clean not used attributes based on clearNotUsed", () {
        spann_span.attributes["class"] = "should be removed";
        mountComponent(defaultDescription, mountRoot, useExisting: true, clearNotUsed: false);
        expect(spann_span.attributes["class"], isNotNull);
      });
    });
  });
}
