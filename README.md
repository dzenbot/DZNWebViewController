DZWebBrowser
================
[![Pod Version](http://img.shields.io/cocoapods/v/DZNWebViewController.svg)](https://cocoadocs.org/docsets/DZNWebViewController)
[![Gittip](http://img.shields.io/gittip/dzenbot.svg)](https://www.gittip.com/dzenbot/)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

An iPhone/iPad simple web browser controller with navigation controls and sharing features:
* Progress bar embeded on the navigation bar (optional).
* Navigation bar shows title animated, à la Twitter official app.
* Sharing options like posting on Twitter, Facebook, Mail, etc. (optional).
* Long press gesture for capturing links and images (optional).
* Customizable toolbar icons.
* iOS7 support.
* Localization support.

![DZWebBrowser](Docs/screenshot.jpg)

DZWebBrowser uses ARC and supports iOS7 and superior.
Also support multiple orientations.

Some additonal feature ideas:
- Hide NavigationBar & ToolBar for larger screen real estate (à la Safari App).
- Optional way of searching a custom URL from the NavigationBar.
- Keywords auto-completion when searching on bar.
- Reload page.

Feel free to fork it and make it more interesting!

## Installation
Available in [Cocoa Pods](http://cocoapods.org/?q=DZWebBrowser)
```
pod 'DZNWebViewController', '~> 2.0.0'
```

## How to use
It is very easy to add DZWebBrowser to your projects. Take a look into the sample project.
Hopefully you saved a couple of hours!

### Step 1
```
Import "DZNWebViewController.h" to your view controller subclass.
```

### Step 2
If not installed with Cocoa Pods:
```
Import Apple's SystemConfiguration, CFNetwork, MessageUI and Social frameworks.
```

### Step 3
Create a new instance of DZNWebViewController and initialize with a NSURL.
You also need to embed the view controller into a UINavigationController.
```
NSURL *URL = [NSURL URLWithString:@"http://www.google.com/"];

DZNWebViewController *webViewController = [[DZNWebViewController alloc] initWithURL:URL];
webViewController.toolbarTintColor = [UIColor whiteColor];
webViewController.toolbarBackgroundColor = [UIColor blackColor];
webViewController.supportedActions = DZNWebViewControllerActionAll;

UINavigationController *webViewNavController = [[UINavigationController alloc] initWithRootViewController:webViewController];

[self presentViewController:webViewNavController animated:YES completion:NULL];
```

## Third party Frameworks

DZWebBrowser requires third party frameworks, if not installed with Cocoa Pods you must add them as submodules:
- [NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress) from [Satoshi Asano](https://github.com/ninjinkun).


## License
(The MIT License)

Copyright (c) 2012 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
