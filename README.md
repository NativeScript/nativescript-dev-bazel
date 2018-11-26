# nativescript-dev-bazel

Plugin that allows you to build [NativeScript](https://www.nativescript.org/) applications with [Bazel](https://bazel.build/).

> NOTE: This is just POC. You should not use this for your production builds.

## Installation and usage
You can add the plugin to your existing NativeScript applications by executing:

```
npm i --save-dev <url>/tarball/master
```

After that you have to prepare the project with:
```
tns prepare android
```

And now you can build it with:
```
bazel build //platforms/android:android
```

## Limitations
* Currently you can build NativeScript applications for Android only.
* In case you are using some plugins that require maven libraries, you may have to add some additional `gmaven` artifacts in the `<project dir>/platforms/android/BUILD.bazel` file.
* You still need to use NativeScript CLI to prepare the project, i.e. you need to execute `tns prepare android` before rebuilding the application.

## FAQ
* How to install built application on Android device?
You can use `bazel` command to directly install the application on emulator (NOTE: the command will also build the app if required):
```
bazel mobile-install //platforms/android:android
```
Another way is to use the `adb` located at `$ANDROID_HOME/platform-tools/adb` and install the built application with it. The command should be:
```
$ANDROID_HOME/platform-tools/adb install -r bazel-bin/platforms/android/android.apk
```

* I'm unable to install the application on Android emulator.
Probably your emulator is using x86 architecture. the default build operation strips this architecture. In order to use emulator, you have to pass `--fat_apk_cpu=x86` arg to `build`/`mobile-install` bazel commands:
```
bazel mobile-install //platforms/android:android --fat_apk_cpu=x86
```

## Contribution
You are more than welcome to contribute to this project. Just clone the repo and you are ready to start.

## License

This software is licensed under the Apache 2.0 license, quoted <a href="LICENSE" target="_blank">here</a>.