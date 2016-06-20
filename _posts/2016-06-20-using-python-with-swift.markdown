---
layout: post
title:  "Using Python With Swift"
date:   2016-06-20 13:08:05 +0100
categories: python swift
excerpt_separator: <!--more-->
---

(TL;DR: Create a python .plugin bundle with `py2app`, load it in `main.swift`
and use `@objc` protocols to specify concrete interfaces for the python classes
to implement)

I wanted to use an existing library of python code that I had written, in a
new macOS application - to provide an easy-to-use UI for the library. I wanted
to use Swift, both because I find it an infinitely nicer language than
Objective-C, and it seems to be the way things are heading.

There is lots of information around on how to integrate python with Objective-C
via the [`pyobjc`][pyobjc] python library, but a lot of information is very old
and I couldn't find anything that discussed or was even as recent as Swift.

The best way to create executable bundles with python is with
[`py2app`][py2app], which has two modes of operation - creating an executable
application `.app` bundle with the main executable written in python and
calling into compiled swift code, and creating a python-based `.plugin` bundle
that is loaded by the Swift-based application. After having various issues 
working with the `.app` method, I decided to use the `.plugin` approach, despite
the relative lack of documentation.

This article shows a very basic application to demonstrate the fundamental
principals of integrating swift and python.

<!--more-->

The aims for the application are:

- A canonical storyboard-based swift app 
- A single window that has a custom NSView
- The view controller for the window is written in swift and calls python code
  in order to get the python version, and prints it to the console
- The NSView is a python-based custom view with a colored background


Basic Integration
-----------------

Let's start by building the very basic infrastructure; a python-based plugin
that is loaded by our swift application, and simply prints to standard output
to let us know that it has been executed.

### 1. Create the XCode project

Start by creating a new OSX Application project in XCode, and set the language to Swift.
I'm calling the application `PythonToSwiftExample`, which doesn't matter except
that it changes the default namespace by which your swift interfaces are exported.
We're also using storyboards.

![Creating the base project](/images/PTS_createProject.png)

There are just a couple of changes to the project at this stage. In order to
allow the storyboards or XIB files to reference python classes (e.g. custom
views or  controllers), the python classes need to be created before the
interface is. Loading of the primary storyboard or XIB is done inside the
`NSApplicationMain` function, before any user-created code is called. We
therefore need to override the default implementation of the `main()` entry
point.

Firstly, go to the generated `AppDelegate.swift` application delegate source,
and remove the class attribute that says `@NSApplicationMain` from the delegate.
This will prevent the default entry from being synthesized.

Secondly, add a new Swift file to the project, and name it `main.swift`. The
name is important, because the first executable line in a swift file with that
name is used as the first piece of code run upon starting the executable. For
now, we just want to replicate the default behavior, so the contents of
`main.swift` are:

```swift
import Cocoa

NSApplicationMain(Process.argc, Process.unsafeArgv)
```

### 2. Create the python .plugin bundle

Now let's create the basic python infrastructure. In the terminal, navigate to
the project root folder you just created. Decide on which python version you
want to use for the plugin - python3 via [`pyenv`][pyenv] is used in this
tutorial, but setting up your python environment is beyond the scope of this
article. Make sure that the python packages `pyobjc` and `py2app` are
installed in your environment:

```
$ pip3 install pyobjc py2app
```

Create a simple placeholder for the entry point into the bundle, that we
call here `Bridge.py`:

```python
"""Bridge.py. The main Python-(Swift) plugin bundle entry module"""
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

logger.info("Loaded python bundle")
```

And create the `setuptools`/`py2app` setup file, `setup.py` to load , with the contents:

```python
"""Setuptools setup for creating a .plugin bundle"""
from setuptools import setup


APP = ['Bridge.py']
OPTIONS = {
  # Any local packages to include in the bundle should go here.
  # See the py2app documentation for more
  "includes": [], 
}

setup(
    plugin=APP,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
    install_requires=['pyobjc'],
)
```
This will allow `py2app` to build a plugin that loads `Bridge.py`, and that
contains the additional package `bridge`, copied into the bundle.

Now let's create the `.plugin` bundle that will be loaded into the
application. Although we are far from useful on the python side, the `-A`
argument will only create an alias to the code location, so that the bundle
does not have to be rebuilt every time the python code changes. Of course, this
is for development only, not distribution.

```
$ python setup.py py2app -A
running py2app
creating /Users/xgkkp/tmp/PythonToSwiftExample/build
creating /Users/xgkkp/tmp/PythonToSwiftExample/build/bdist.macosx-10.11-x86_64
creating /Users/xgkkp/tmp/PythonToSwiftExample/build/bdist.macosx-10.11-x86_64/python3.5-standalone
creating /Users/xgkkp/tmp/PythonToSwiftExample/build/bdist.macosx-10.11-x86_64/python3.5-standalone/app
creating /Users/xgkkp/tmp/PythonToSwiftExample/build/bdist.macosx-10.11-x86_64/python3.5-standalone/app/collect
creating /Users/xgkkp/tmp/PythonToSwiftExample/build/bdist.macosx-10.11-x86_64/python3.5-standalone/app/temp
creating /Users/xgkkp/tmp/PythonToSwiftExample/dist
creating build/bdist.macosx-10.11-x86_64/python3.5-standalone/app/lib-dynload
creating build/bdist.macosx-10.11-x86_64/python3.5-standalone/app/Frameworks
*** creating plugin bundle: Bridge ***
Done!
```

We now have a working, active `.plugin` bundle, in `dist/Bridge.plugin`. Let's
now integrate this into our application. Back to XCode.

### 3. Loading the .plugin

In XCode, go to `File -> Add Files to "PythonToSwiftExample"...`. Browse to the
`PROJECT_ROOT/dist` folder, select `Bridge.plugin` and click add. The plugin will
now be copied into the application bundle when you build inside XCode.

Now let's actually load the plugin. Alter the `main.swift` entry point file so
that it locates and loads the plugin bundle:

```swift
// Application main entry point

import Cocoa

let path = Bundle.main().pathForResource("Bridge", ofType: "plugin")
guard let pluginbundle = Bundle(path: path!) else {
  fatalError("Could not load python plugin bundle")
}
pluginbundle.load()

NSApplicationMain(Process.argc, Process.unsafeArgv)
```
And now we can run the application! If everything is working correctly, then
a blank window should open and the python logging output should be visible in
the XCode output window:

![Basic output](/images/PTS_basicOutput.png)

More Useful Behaviour: Integration
----------------------------------

Now we have the very basic infrastructure, let's actually write code that
communicates between swift and python. With `pyobjc`, a python class needs to
inherit from `NSObject` in order to be visible to Objective-C.  Using Swift,
any objects passed to python need to inherit from an Objective-C class, or
annotated with the `@objc` attribute - this ensures that they are created and
passed as Objective-C objects. For more details, see the Swift
[attributes] documentation.

We will be communicating with python in a couple of ways:

- Create the NSObject-derived class in python, and load dynamically in Swift
  with `NSClassFromString`. This is effectively what happens when using named
  python-based classes in the storyboards and XIBs.
- Take advantage of the bundles [principal class] to be handed
  a class with an expected interface.

In order to use the principal class we need to know the interface it adheres
to. Since this is a custom interface, it is unlikely that any existing
protocol will be suitable, and with Swift we can't just rely on knowing we are
sending the right messages. So, let's create an Objective-C protocol, subclass
from it in python, and then instantiate it in Swift.

### Loading the .plugin Principal class

Create a new Swift file in the XCode project, named `BridgeInterface.swift`:

```swift
import Foundation

/// A simple demonstration interface to the python module
@objc public protocol BridgeInterface {
  static func createInstance() -> BridgeInterface
  func getPythonInformation() -> String
}

/// A simple class for access to an instance of the python interface
class Bridge {
  static private var instance : BridgeInterface?
  
  static func sharedInstance() -> BridgeInterface {
    return instance!
  }
  static func setSharedInstance(to: BridgeInterface?) {
    instance = to
  }
}
```

This gives us an Objective-C protocol, `BridgeInterface` with a class method
to instantiate itself (this works because the method implementation is
dynamically dispatched to the `Type` reference we will have shortly), and a
simple instance method `getPythonInformation` that will just return a
`String`. We also have a convenience accessor class - `Bridge`. This lets us
worry about how to get hold of our initial instance of `BridgeInterface` only
once, and the rest of the program can use the convenience class afterwards.

Let's see this in practice; edit `main.swift` to put this after the call to
`pluginbundle.load()` and before the call to `NSApplicationMain`:

```swift
// Load the principal class
guard let pc = pluginbundle.principalClass as? BridgeInterface.Type else {
  fatalError("Could not load principal class from python bundle")
}

// Create an instance of the principal class and store it
let interface = pc.createInstance()
Bridge.setSharedInstance(to: interface)
Bridge.sharedInstance().
```

And, to prove that we can now use this in the main application, go to the
autogenerated `ViewController.swift` and add the following lines into the
`viewDidLoad` function:

```swift
let pythonMessage = Bridge.sharedInstance().getPythonInformation()
Swift.print("Info from python:\n\(pythonMessage)")
```

### Creating the Principal Class

Running at this point will simply get the error

    fatal error: Could not load principal class from python bundle

because we have not yet create the class in python! Although `py2app` lets you 
customize the principal class (via the bundles `Info.plist`) the default is
a class with the same name as the bundle, which in this case would be `Bridge`.

Let's look at the lines we are adding to `Bridge.py` (since we only had logging
before, it shouldn't matter if you instead replace the contents):

```python
import sys
import objc
from Foundation import NSObject

# Load the protocol from Objective-C
BridgeInterface = objc.protocolNamed("PythonToSwiftExample.BridgeInterface")

class Bridge(NSObject, protocols=[BridgeInterface]):
  @classmethod
  def createInstance(self):
    return Bridge.alloc().init()

  def getPythonInformation(self):
    return sys.version

```

The first important part here is loading the protocol; Because we are using a
swift application bundle, the protocol is prefixed by the Swift modules name
(whereas with plain Objective-C this might not be the case). 

Secondly is the way in which we declare our `Bridge` class - due to the nature
of the `pyobjc` bridge, inheriting from a protocol does not correctly create
an Objective-C dynamic NSObject. The syntax displayed here is **only** valid
for Python 3 upwards - see the `pyobjc` documentation for older methods of
declaring protocol conformance.

Now, running the swift application should work - loading a blank window, 
and spitting out the python version information into the output log.

### Custom NSView in python

Lastly, let's demonstrated creating a custom NSView that simply colours it's
background. In XCode, open `Main.storyboard`. Drag out a "Custom View" from
the toolbox to the main view controller, go to the properties tab and change
the "Custom Class"-"Class" field to read `ColouredView`.

![Adding a custom view](/images/PTS_storyboard.png)

Now go back to `Bridge.py`. Add the following imports to the module:

```python
from Cocoa import NSView
from AppKit import NSGraphicsContext, NSRectToCGRect
import Quartz
```

and add the following class declaration; we are creating an NSView subclass
that overrides the `drawRect:` selector. The underscore is required, as per
the `pyobjc` [naming rules], but otherwise the calls should be
relatively familiar:

```python
class ColouredView(NSView):
   def drawRect_(self, dirtyRect):
     context = NSGraphicsContext.currentContext().CGContext()
     Quartz.CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0)
     Quartz.CGContextFillRect(context, dirtyRect)
```

and running this gives the expected, complete output:

![Swift and Python combined output](/images/PTS_output.png)




[pyobjc-embedded]: https://pythonhosted.org/pyobjc/tutorials/embedded.html
[pyobjc]: https://pythonhosted.org/py2objc/
[py2app]: https://pythonhosted.org/py2app/
[pyenv]: https://github.com/yyuu/pyenv
[attributes]: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Attributes.html
[principal class]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/#//apple_ref/occ/instp/NSBundle/principalClass
[naming rules]: https://pythonhosted.org/pyobjc/core/intro.html#underscores-and-lots-of-them
