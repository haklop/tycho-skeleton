#!/bin/bash
usage(){
  echo "Usage: $0 target package title"
	exit 1
}

if [[ ! -n "$3" ]]
then
  usage
fi

echo "Creating target structure"

if [ -d "$1" ]
then
  rm $1/* -rf
  echo "### !!! FIXME !!! ###"
else
  mkdir $1
fi

mkdir $1/$2/{icons,META-INF,src} -p

IFS=. read -r -a packages <<< $2
fullDir=$1/$2/src/
for package in $packages; do
  fullDir="$fullDir$package/"
done
mkdir $fullDir -p
mkdir $1/$2.parent
mkdir $1/$2.target
mkdir $1/$2.product

echo "[0/5] Building project"
echo "[1/5] Building Eclipse Plug-In Project"

files="bundle/plugin.xml
bundle/.classpath
bundle/.project
bundle/build.properties
bundle/META-INF/MANIFEST.MF
bundle/pom.xml
bundle/plugin_customization.ini"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$2/g" < $file | sed "s/{{ RCP_TITLE }}/$3/g" > $file.tmp
  mv $file.tmp $1/$2/${file:7}
done

files=bundle/src/*
for file in $files ;do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$2/g" < $file | sed "s/{{ RCP_TITLE }}/$3/g" > $file.tmp
  mv $file.tmp $fullDir/${file:11}
done

echo "[2/5] Building Parent Project"
files="parent/pom.xml"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$2/g" < $file | sed "s/{{ RCP_TITLE }}/$3/g" > $file.tmp
  mv $file.tmp $1/$2.parent/${file:7}
done

echo "[3/5] Building Target Project"
files="target/pom.xml
target/indigo.target"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$2/g" < $file | sed "s/{{ RCP_TITLE }}/$3/g" > $file.tmp
  mv $file.tmp $1/$2.target/${file:7}
done

echo "[4/5] Building Product Project"
files="product/pom.xml
product/product.product"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$2/g" < $file | sed "s/{{ RCP_TITLE }}/$3/g" > $file.tmp
  mv $file.tmp $1/$2.product/${file:8}
done
