# Android Overlay Packaging Tool (DEPRECATED)

NOTE: As of commit [`3b764ebc`](https://github.com/substratum/substratum/commit/3b764ebc09991b14b06dee074a1633ef4f5169d5) ("AAPT: unify binaries for all architectures"), AOPT is deprecated. The source is just normal AAPT from Google ([link](https://android.googlesource.com/platform/frameworks/base/+log/master/tools/aapt)).

This is our modified version of Android's Android Asset Packaging Tool (AAPT), specifically for compiling OMS overlays.

To build it, either clone this repo in your ROM's "external" folder or add it as a line to your manifest, placing it in "external/aopt". After that, run your normal command:

```bash
. build/envsetup.sh
lunch
make -j# aopt
```
