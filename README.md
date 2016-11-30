
[![CI Status](https://api.travis-ci.org/GirAppe/Blackhole.svg?style=flat&branch=master)](https://travis-ci.org/GirAppe/Blackhole)
[![Version](https://img.shields.io/cocoapods/v/Blackhole.svg?style=flat)](http://cocoapods.org/pods/Blackhole)
[![License](https://img.shields.io/cocoapods/l/Blackhole.svg?style=flat)](http://cocoapods.org/pods/Blackhole)
[![Platform](https://img.shields.io/cocoapods/p/Blackhole.svg?style=flat)](http://cocoapods.org/pods/Blackhole)

# Blackhole

![Blackhole logo](https://raw.githubusercontent.com/GirAppe/Blackhole/develop/Icon-60%402x.png)

__Blackhole__ is delightful iOS to watchOS communication framework, based on WatchConnectivity framework's WCSession.

Utilizes Wormhole concept, that simplifies data sync between iOS and watch devices. Also, provides set of handful protocols, allowing to create easily synchronized custom model classes.

Some of the features:
 - start listeners, waiting for given communication message identifiers
 - send simple messages
 - send every object, that can be represented as Data
 - request any object from counterpart app, be sending a message and specifying success handler
 - all public api wrapped in convenient promises implementation (BrightFutures)

Must to have for watchOS development.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Requirements

Blackhole requires __iOS 9.0+__, and __watchOS 3.0+__. It requires __Swift 3.0.1__.

## Installation

Blackhole is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Blackhole"
```

or, if you intend to use it with [BrightFutures](https://github.com/Thomvis/BrightFutures) (__recommended!!!__)

````ruby
pod "Blackhole/BrightFutures"
````
BrightFutures is great promises implementation, and it works with Blackhole like a charm. It allows to easily wrap async communication within app and phone (see the example app for reference). If you need more info on promises topis - check GirAppe blog post: [*"Promises, unravelling the spaghetti code"*](http://blog.girappe.com/?promisekit).


## Author

Andrzej Michnia, amichnia@girappe.com

## License

Blackhole is available under the MIT license. See the LICENSE file for more info.
