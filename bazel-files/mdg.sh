# mdg.sh is a HACK
# This is a workaround for the behavior of android-metadata-generator.jar
# which hard-codes assumptions about paths on disk in the environment where
# it runs in the nativescript gradle build.
# We reproduce an identical environment before calling out to the tool

set -e -x

DIR=$PWD
JAR=$1
RESOURCE_JAR=$2
CLASSES_TMP=$3
DEPS_FILE=$4
shift
shift
shift
shift

(
  mkdir $CLASSES_TMP
  cd $CLASSES_TMP
  $DIR/$JAR xf $DIR/$RESOURCE_JAR
  for j in $(cat $DIR/$DEPS_FILE); do $DIR/$JAR xf $DIR/$j; done
)
# ls -R $CLASSES_TMP


# Move mdg-dependencies-java.txt
cp -p $DEPS_FILE .
echo $CLASSES_TMP >> mdg-dependencies-java.txt

# Move sbg-output-dir.txt
cp -p $1 .
# Silence a warning:
# Couldn't find the output dir [...] or it wasn't a directory so it will be created!
mkdir $(cat $1)
shift

# Uncomment these for some helpful debugging
# Another debugging technique is to locally modify
# $(bazel info output_base)/external/tns_android/build-tools/jsparser/js_parser.js
# with some extra println debugging
#find . -name *.jar >&2
#find . -name ts_helpers.js >&2
# ls -alF jsparser
#pwd

# Okay, the environment now mimics the nativescript gradle build
# So we take the remaining command line args and replace this bash
# process with that one.
exec "$@"
