# Android Overlay Packaging Tool

This is our modified version of Android's Android Asset Packaging Tool (AAPT), specifically for compiling OMS overlays.

To build it, either clone this repo in your ROM's "external" folder or add it as a line to your manifest, placing it in "external/aopt". After that, run your normal command:

```bash
. build/envsetup.sh
lunch
make -j# aopt
```
