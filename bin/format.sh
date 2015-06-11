#! /bin/bash

for i in `find -name *.dart`; do 
	dartfmt $i -w
done

