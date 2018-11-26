# sbg.sh is a HACK
# This is a workaround for the behavior of static-binding-generator.jar
# which hard-codes assumptions about paths on disk in the environment where
# it runs in the nativescript gradle build.
# We reproduce an identical environment before calling out to the tool

# dirname of Node is the first arg
# the tool expects to execute node from the PATH
export PATH=$PATH:$1
# echo $PATH
shift

# Move jsparser
mkdir jsparser
mv $1 jsparser/
shift

# Move sbg-dependencies-java.txt
cp -p $1 .
shift

# Move sbg-input-file.txt
# Also make the path it contains absolute, since there is some
# path munging logic in js_parser that uses a simple length-based logic:
# data.filePath.substring(inputDir.length + 1, (data.filePath.length - 3))
# https://github.com/NativeScript/android-runtime/blob/d194bc9329a9175c7bc18d30db1408193aba5e27/test-app/build-tools/jsparser/js_parser.js#L239
(echo -n "$PWD/"; cat $1) > sbg-input-file.txt
(echo -n "$PWD/"; cat $1) > external/tns_android/build-tools/sbg-input-file.txt
shift

# Move sbg-output-file.txt
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
