format:
	sh bin/format.sh
	
analyze: 
	for i in `ls lib/*.dart`; do dartanalyzer $$i; done

