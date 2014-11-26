DZWebBrowser 3.0
================
[![Pod Version](http://img.shields.io/cocoapods/v/DZNWebViewController.svg)](https://cocoadocs.org/docsets/DZNWebViewController)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

An iPhone/iPad mini WebKit browser controller with navigation controls and contextual features, useful for in-app web browsing.
Built to be subclassed and extended.

![DZWebBrowser](Docs/screenshot.jpg)

### Features
* Load HTTP links or local HTML.
* Navigation tools: backward/foward/stop/reload.
* Dragging gestures for back/forward, like Safari app.
* Back/forard History (optional).
* Progress bar embeded on the navigation bar or activity indicator (optional).
* Hide top and bottom bars when scrolling, like Safari app (optional).
* Contextual features: share link, copy link, read later.
* Open in Safari, Chrome, Opera Mini & Dolphin.
* Customizable toolbar icons.

### Supports
* Portrait/Landscape
* Localization
* iPhone/iPad
* Retina & iPad6+ displays
* iOS8 only
* ARC

## Installation
Available in [Cocoa Pods](http://cocoapods.org/?q=DZWebBrowser)
```
pod 'DZNWebViewController'
```

## How to use

Create a new instance of DZNWebViewController, or your custom subclass, and initialize it with a NSURL.
You must embed the view controller into a UINavigationController to make it work properly.
```
NSURL *URL = [NSURL URLWithString:@"http://www.google.com/"];

DZNWebViewController *WVC = [[DZNWebViewController alloc] initWithURL:URL];
UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:WVC];

WVC.supportedWebNavigationTools = DZNWebNavigationToolAll;
WVC.DZNsupportedWebActions = DZNWebActionAll;
WVC.showLoadingProgress = YES;
WVC.allowHistory = YES;
WVC.hideBarsWithGestures = YES;

[self presentViewController:NC animated:YES completion:NULL];
```

## License
(The MIT License)

Copyright (c) 2014 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
