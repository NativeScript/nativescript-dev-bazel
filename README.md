# nativescript-dev-bazel

Plugin that allows you to build [NativeScript](https://www.nativescript.org/) applications with [Bazel](https://bazel.build/).

> NOTE: This is just POC. You should not use this for your production builds.

## Prerequisites
You need to install the following tooling:
1. [NativeScript CLI](https://www.npmjs.com/package/nativescript)
2. [Bazel](https://docs.bazel.build/versions/master/install.html)
3. [Android Studio](https://developer.android.com/studio/install) with the following SDK components installed:
  - Android SDK 28 or later
  - Android SDK Build-Tools 28 or later
  - Android SDK Platform-Tools 28 or later
  - Android SDK Tools 26 or later
  - NDK 19 or later
4. [Git](https://git-scm.com/downloads)

## Installation and usage

You can add the plugin to your existing NativeScript applications by executing:

```
npm i --save-dev https://github.com/NativeScript/nativescript-dev-bazel/tarball/master
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
* `How to install built application on Android device?` </br>
You can use `bazel` command to directly install the application on emulator (NOTE: the command will also build the app if required):
```
bazel mobile-install //platforms/android:android
```
Another way is to use the `adb` located at `$ANDROID_HOME/platform-tools/adb` and install the built application with it. The command should be:
```
$ANDROID_HOME/platform-tools/adb install -r bazel-bin/platforms/android/android.apk
```

* `I'm unable to install the application on Android emulator.` </br>
Probably your emulator is using x86 architecture. the default build operation strips this architecture. In order to use emulator, you have to pass `--fat_apk_cpu=x86` arg to `build`/`mobile-install` bazel commands:
```
bazel mobile-install //platforms/android:android --fat_apk_cpu=x86
```

* `How can I use Angular's AOT?`</br>
Currently the Bazel rules for Angular applications are not included in the Bazel rules for building NativeScript application. So, one way to use AOT is by including the Angular rules in the BUILD.bazel file in `<project dir>/platforms/android`. This is not an easy task, but in case you succeed, feel free to open PR to this repo, so other people will be able to use the rules.</br>
Another way to use AOT is by preparing your application with the following command: `tns prepare android --bundle --env.aot`. This way NativeScript CLI will use the Angular compiler to prepare the application's code. After that you can build the app with `bazel build //platforms/android:android`

## Contribution
You are more than welcome to contribute to this project. Just clone the repo and you are ready to start.
You can search for `# TODO` in the code for the places where we've identified something needs to be implemented/fixed or just check the logged issues.

## License

This software is licensed under the Apache 2.0 license, quoted <a href="LICENSE" target="_blank">here</a>.