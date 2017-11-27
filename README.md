<p align="center">
  <img width="40%" height="40%" src="https://github.com/intelygenz/Archit-iOS/raw/develop/Logo.png">
</p>

# Intelygenz iOS Architecture

[![Twitter](https://img.shields.io/badge/contact-@intelygenz-0FABFF.svg?style=flat)](http://twitter.com/intelygenz)
[![Build Status](https://travis-ci.org/intelygenz/Archit-iOS.svg?branch=master)](https://travis-ci.org/intelygenz/Archit-iOS)
[![License](https://img.shields.io/github/license/intelygenz/Archit-iOS.svg?style=flat)](https://github.com/intelygenz/Archit-iOS/blob/master/LICENSE)
[![codebeat badge](https://codebeat.co/badges/fbe5c86d-c2b3-4d7d-9ba0-93b72508e310)](https://codebeat.co/projects/github-com-intelygenz-archit-ios-master)

This repository contains an iOS architecture documentation with a sample application that uses [OMDb API](http://www.omdbapi.com) and implements the Archit architecture.

## 🔨 Xcode Configuration

* You should enable **Xcode Text Editing** options:
	1. Line numbers. (Specify a line to a mate or search for a crash)
	2. Code folding ribbon. (Optional)
	3. Page guide at column: 140 (No line should exceed it, so we will all read the same code)
	4. Including whitespace-only lines. (Lighter files)

	![Xcode Text Editing](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/xcode_text_editing.png)
 
## 🔧 Project Installation

* Install **[XcodeGen](https://github.com/yonaskolb/XcodeGen#installing)**:

```
$ brew tap yonaskolb/XcodeGen https://github.com/yonaskolb/XcodeGen.git
$ brew install XcodeGen
```

* Clone **[Archit](https://github.com/intelygenz/Archit-iOS/releases)**:

```
$ git clone https://github.com/intelygenz/Archit-iOS.git
$ cd Archit-iOS
```

* Run **[XcodeGen](https://github.com/yonaskolb/XcodeGen#usage)** in Archit clone root directory:

```
$ xcodegen
```

## 🔧 Project Configuration

* Configure the **breakpoints**:

	In the Breakpoint navigator, create an "Exception Breakpoint...":

	![Exception Breakpoint](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/exception_breakpoint.png)

	Also create a "Symbolic Breakpoint..." with "UIViewAlertForUnsatisfiableConstraints" as "Symbol":

	![Unsatisfiable Constraints Breakpoint](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/unsatisfiable_constraints_breakpoint.png)

## 🤓 Usage

### AppManager

We delegate all responsibilities of the AppDelegate to an AppManager under our control, testable and that will be in charge of initializing all third-party frameworks that need initialization in the didFinishLaunching for example.

In addition, if we need location services, notifications, etc. We will create independent managers for each of them, and only their implementation will have access to the specific frameworks.

![AppManager](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/app_manager.png)

### VCI (ViewController Controller Interactor)

We will create base view controllers for each of the native view controllers we need, all the application view controllers will inherit from these base view controllers.

Each view controller will be injected with the corresponding controller depending on whether we are developing, testing or in production, so we can mock what we want.

Each controller will have an interactor who will be in charge of calling the asynchronous core framework tasks, generating a [Kommand](https://github.com/intelygenz/Kommander-iOS/blob/master/Source/Kommand.swift) and passing it to the controller for execution and response handling.

![VCI (ViewController Controller Interactor)](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/vci.png)

### Core Framework

Only the StorageManager knows the existence of the persistence framework that is used.

There will be intermediate StorageModels to map/parse the application model and store/update/fetch them in the database.

Only the HTTPClient knows the existence of the networking framework that is used.

There will be intermediate NetworkModels to map/parse the application model and get/post/put them to the network.

The service has tasks for each network API call related with the same context (application model, use case, web service).

![Core Framework](https://raw.githubusercontent.com/intelygenz/Archit-iOS/master/Resources/core_framework.png)

### CocoaPods

Every networking layer must be implemented around **[Net](https://github.com/intelygenz/NetClient-iOS/blob/master/Core/Net.swift)** protocol.

By default, we'll use **[NetClient](https://github.com/intelygenz/NetClient-iOS)** for networking.

We can use **[Kommander](https://github.com/intelygenz/Kommander-iOS)** to manage asynchronous processes, but always outside the **[Core Framework](#core-framework)**.

To instantiate or reuse Storyboards, ViewControllers, Views, UITableViewCells or UICollectionViewCells, you must use **[Reusable](https://github.com/AliSoftware/Reusable)**.

To handle Dates and Timezones, we could use **[SwiftDate](https://github.com/malcommac/SwiftDate)**.

We MUST use **[ATTD](https://en.wikipedia.org/wiki/Acceptance_test–driven_development)** with **[HonestCode](http://honestcode.io)**, therefore we'll need **[Cucumberish](https://github.com/Ahmed-Ali/Cucumberish)**.

In order to use user location, we will use **[IGZLocation](https://github.com/intelygenz/IGZLocation)**.

When we need to modify Auto Layout programmatically, we could use **[SnapKit](https://github.com/SnapKit/SnapKit)**.

For async image loading we could use **[Kingfisher](https://github.com/onevcat/Kingfisher)**.

To use NotificationCenter, **[SwiftNotificationCenter](https://github.com/100mango/SwiftNotificationCenter)** is recommended.

To display the progress of an ongoing task, you could use **[SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)** or **[SkeletonView](https://github.com/Juanpe/SkeletonView)**.

To securely store data, we use **[Valet](https://github.com/square/Valet)**.

As logging library, we love **[XCGLogger](https://github.com/DaveWoodCom/XCGLogger)**.

## ❤️ Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## 👨🏻‍💻 Authors

**[alexruperez](https://github.com/alexruperez)**, alejandro.ruperez@intelygenz.com

## 👮🏻 License

Archit is available under the MIT license. See the LICENSE file for more info.
