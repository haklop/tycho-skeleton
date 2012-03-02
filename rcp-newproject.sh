#!/bin/bash

function usage {
  cat <<- EOT
  Create an empty Tycho project.
  
  usage : $0 [[-d directory] [-p package] [-n name] [--tycho]] [-h]
  
    -d --destination directory 
    -p --package     Name of the based package of the Eclipse RCP application
    -n --name        Name of the application
    --tycho          Defined the version of Tycho: 0.12.0, 0.13.0 and 0.14.1 are supported. 0.14.1 is the default value.
    -h --help        Display this message
EOT
}

#-------------------------------------------------------------------------------
# Cleanup temporary file in case of keyboard interrupt or termination signal.
#-------------------------------------------------------------------------------
function cleanup_temp_file {
  # TODO
  exit 0
}

trap cleanup_temp_file SIGHUP SIGINT SIGPIPE SIGTERM

folder=
package=
title=
tycho_version=0.14.1
while [  $# -gt 0 ]; do
  case $1 in
    -d | --destination )
      shift
      folder=$1
      ;;
    -p | --package )
      shift
      package=$1
      ;;
    -n | --name )
      shift
      title=$1
      ;;
    --tycho )
      shift
      tycho_version=$1
      ;;
    -h | --help )
      usage
      exit
      ;;
    * )
      usage
      exit 1
  esac
  shift
done

# Checking arguments
if [[ $folder == "" || $package == "" || $title == "" ]]
then
  usage
  exit 1
fi

echo "[0/5] Building project"
echo "[1/5] Creating target structure"

if [ ! -d "$folder" ]
then
  mkdir $folder 2> /dev/null
  if [ $? -ne 0 ]
  then
    echo "[ERROR] The destination is not a directory"
    exit 1
  fi
fi

mkdir $folder/$package/{icons,META-INF,src} -p

IFS=. read -r -a packages <<< $package
fullDir=$folder/$package/src/
for subpackage in $packages; do
  fullDir="$fullDir$subpackage/"
done
mkdir $fullDir -p
mkdir $folder/$package.parent
mkdir $folder/$package.target
mkdir $folder/$package.product

echo "[2/5] Building Eclipse Plug-In Project"

files="bundle/plugin.xml
bundle/.classpath
bundle/.project
bundle/build.properties
bundle/META-INF/MANIFEST.MF
bundle/pom.xml
bundle/plugin_customization.ini"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$package/g" < $file | sed "s/{{ RCP_TITLE }}/$title/g" > $folder/$package/${file:7}
done

files=bundle/src/*
for file in $files ;do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$package/g" < $file | sed "s/{{ RCP_TITLE }}/$title/g" > $fullDir/${file:11}
done

echo "[3/5] Building Parent Project"
files="parent/pom.xml"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$package/g" < $file | sed "s/{{ RCP_TITLE }}/$title/g" | sed "s/{{ TYCHO_VERSION }}/$tycho_version/g" > $folder/$package.parent/${file:7}
done

echo "[4/5] Building Target Project"
files="target/pom.xml
target/indigo.target"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$package/g" < $file | sed "s/{{ RCP_TITLE }}/$title/g" > $folder/$package.target/${file:7}
done

echo "[5/5] Building Product Project"
files="product/pom.xml
product/product.product"

for file in $files; do
  echo "Processing $file"
  sed "s/{{ RCP_PACKAGE }}/$package/g" < $file | sed "s/{{ RCP_TITLE }}/$title/g" > $folder/$package.product/${file:8}
done
