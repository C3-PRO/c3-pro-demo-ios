C3-PRO iOS App Demo
===================

> NOTE that the C3-PRO framework is not yet Open Source so you can't use this demo app just yet.

A simple iOS/Swift app demonstrating how the C3-PRO iOS framework can be used.


## Learn

All code needed are contained in individual `C3Demo` subclasses, take a look at the source files to see how things work.


## Swift vs. Objective-C

The framework is written in Swift and not (usefully) usable from an Objective-C app.
If you develop in Objective-C, we suggest you [**mix and match**](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID124) Swift and Objective-C within your app, meaning you interface with the C3-PRO through Swift.
This can be cut down to a minimum so should not impose a barrier too high on those not accustomed with Swift.


## Installation

Clone this repository and you'll be able to Build & Run immediately:

```
git clone --recursive https://github.com/chb/c3-pro-demo-ios.git
cd c3-pro-demo-ios
open c3-pro-demo-ios.xcodeproj
```

You only need to look at [`C3Demo.swift`](https://github.com/chb/c3-pro-demo-ios/blob/master/c3-pro-demo-ios/C3Demo.swift)'s `viewController()` method to see how individual parts of the framework are used in this sample app.
For documentation refer to the [C3-PRO iOS framework documentation]().
Be sure to look at the console – the framework will warn you about issues such as missing files.


## Example Content

The files that are included in the project are added in a way that's best to get an overview over which files are needed for which task.
It may not be the best way to include files in your project; images for example should go into an _xcassets_ bundle.

Logos added to this sample project contain trademarked material that you may not use in your own app.
Also, **some animation videos used during consent are missing**.
You can find them in the repos of other ResearchKit apps.

🏂
