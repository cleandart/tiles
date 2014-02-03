format:
	sh bin/format.sh
	
analyze: 
	for i in `ls lib/*.dart`; do dartanalyzer $$i; done

test: analyze
	dart test/all.dart;

