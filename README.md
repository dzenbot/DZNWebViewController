# DZWebBrowser

iPhone/iPad controller simple web browser with toolbar options (backward, forward, stop loading and export/share).
Feel free to fork it and make it more interesting!

DZWebBrowser uses ARC and supports iOS6 and under.

![DZWebBrowser](https://dl.dropboxusercontent.com/u/2452151/Permalink/DZWebBrowser.png)


## How to use
It is very easy to integrate into your projects. Take a look into the sample project.

Enjoy it! Hopefully you saved a couple of hours xD

### Step 1
```
Import "DZWebBrowser.h" to your view controller subclass.
```

### Step 2
```
Import Apple's SystemConfiguration, CFNetwork, MessageUI and Social frameworks.
```

### Step 3
Instantiate a DZWebBrowser object and init with a NSURL.
You also need to embed the view controller into a UINavigationController.
```
NSURL *URL = [NSURL URLWithString:@"https://www.google.com/"];
DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initBrowserWithURL:URL];
webBrowser.showProgress = YES;

UINavigationController *webBrowserNC = [[UINavigationController alloc] initWithRootViewController:webBrowser];

[self presentModalViewController:webBrowserNC animated:YES];
```

## Third party Frameworks and iOS Categories

DZWebBrowser requires Apple's Reachability, but the ARC version from @tonymillion (https://github.com/tonymillion/Reachability).

## License
(The MIT License)

Copyright (c) 2012 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
