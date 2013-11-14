rm *.jar
rm -Rf classes/*
javac -d classes src/*
jar cf dummyjavaparser.jar classes/
