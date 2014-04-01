format:
	sh bin/format.sh
	
analyze: 
	for i in `ls lib/*.dart`; do dartanalyzer $$i; done

test: analyze
	bash test/run.sh;

testcore: 
	bash test/run.sh -c

testbrowser: 
	bash test/run.sh -b

testselenium: 
	bash test/run.sh -s
