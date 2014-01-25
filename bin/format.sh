#! /bin/bash

for i in `find -name *.dart`; do 
	#echo $i;
	#sed -i 's///g' $i;

	# https://www.dartlang.org/articles/style-guide/#do-use-a-space-before--in-function-and-method-bodies
	sed -i 's/){/) {/g' $i;

	# https://www.dartlang.org/articles/style-guide/#do-use-a-space-after-flow-control-keywords
	sed -i 's/if(/if (/g' $i;
	sed -i 's/else(/else (/g' $i;
	sed -i 's/catch(/catch (/g' $i;
	sed -i 's/try{/try {/g' $i;
	sed -i 's/while(/while (/g' $i;

	# https://www.dartlang.org/articles/style-guide/#dont-use-a-space-after---and--or-before---and-
	sed -i 's/( /(/g' $i;
	sed -i 's/\[ /[/g' $i;
	sed -i 's/{ /{/g' $i;
	sed -i 's/\(\w\) *)/\1)/g' $i;
	sed -i 's/\(\w\) *]/\1]/g' $i;
	sed -i 's/\(\w\) *}/\1}/g' $i;

	# https://www.dartlang.org/articles/style-guide/#do-place-spaces-around-in-and-after-each--in-a-loop
	sed -i 's/;\(\w\)/; \1/g' $i;

	# https://www.dartlang.org/articles/style-guide/#do-use-a-space-after--in-named-parameters-and-named-arguments
	sed -i 's/:\([^\s ]\)/: \1/g' $i;
	sed -i 's/package: /package:/g' $i;
	sed -i 's/dart: /dart:/g' $i;

done

for i in `find . -type f -not -iwholename '*/.*' -not -iwholename '*/packages/*' -not -iwholename '*~'`; do
	c=`tail -c 1 $i`
	if [ "$c" != "" ]; then 
		echo "No EOF newline - $i"; 
		echo "\n" >> $i;
	fi
done

