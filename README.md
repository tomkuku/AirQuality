<h1 align="center">Air Quality</h1>
<h3 align="center">App to check the air quality</h3>

</br>

<p align="center">
<img alt="Swift Version" src="https://img.shields.io/badge/5.10-red?style=flat&logo=Swift&logoColor=white&label=Swift&labelColor=light_gray&color=orange"/>
<img alt="Platforms" src="https://img.shields.io/badge/iOS_17.0%2B-red?style=flat&logo=apple&logoColor=white&label=platforms&labelColor=light_gray&color=blue"/>

</br>

<p align="center">
<img src="ReadmeImages/emptyObservedStationsList.png" alt="screenshot" width="200" />
<img src="ReadmeImages/observedStationsList.png" alt="screenshot" width="200" />
<img src="ReadmeImages/provincesList.png" alt="screenshot" width="200" />
<img src="ReadmeImages/provincesListWithSearching.png" alt="screenshot" width="200" />
<img src="ReadmeImages/provinceStations.png" alt="screenshot" width="200" />
<img src="ReadmeImages/provinceStationsWithSelections.png" alt="screenshot" width="200" />
<img src="ReadmeImages/selectedStation.png" alt="screenshot" width="200" />
<img src="ReadmeImages/theNearestStation.png" alt="screenshot" width="200" />

</br>

#### **Table of Content**:
- [Architecture](#architecture)
    - [Presentation Layer](#presentation-layer)
    - [DataSource Layer](#datasource-layer)
- [Concurrent code](#concurrent-code)
- [Dependency Injection](#dependency-injection)
- [Code generation](#code-generation)
- [Tests](#tests)
    - [Unit Tests](#unit-tests)
    - [UI Tests](#ui-tests)
        - [Network Mocking](#network-mocking)
        - [Snapshot Testing](#snapshot-testing)
- [CI/CD](#cicd)
    - [UI Tests](#ui-tests)
    - [Danger](#Danger)
- [Tools and dependencies](#tools-and-dependencies)

</br>

# Architecture
This application follows the Clean Architecture principles.

Check out more: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

### Presentation Layer
The presentation layer of this application is built entirely using `SwiftUI` in combination with the `MVVM+C` (Model-View-ViewModel-Coordinator) pattern.

The navigation in this app is powered by SwiftUI's `NavigationView` with `NavigationPath`.

### DataSource Layer
- `Alamofire` library is used to perform HTTPS requests.
- `SwiftData` framework is used to store data.
- `CoreLocation` framework is used to retrieve the user's location.

# Concurrent code
The concurrent code in this project is implemented using the `Swift Concurrency` library. `Strict Concurrency Checking` setting is set to `Complete`.
All cases which **cannot be written** using the Concurrency library, are achieved by `Combine` library.

# Dependency Injection
Dependency Injection is implemented using `protocol`, `property wrapper`, `subscript`, `KeyPath`, and `Mirror`. `KeyPath` provide a major advantage by ensuring type **safety at compile time**. The `Root` type of a `KeyPath` is defined to require an object conforming to `AllDependencies` typealias, which aggregates all dependency protocols. Swift `subscript` enable easy access to specific object via its `KeyPath`, while `@Inject` property wrapper simplify implementation and reduce boilerplate code. This way

For the application code, `Mirror` reflects the `DependenciesContainer` and returns an object's instance matching the provided KeyPath's type and name. For testing, dependencies are stored in a dictionary: `[PartialKeyPath<AllDependencies>: Any]`, making it easier to inject mock dependencies.

This way it's **not possible** to access to an object that has not been declared in the `DependenciesContainer` and this **reduces number of app failures to a minimum**.

# Code generation
- `SwiftGen` is used to generate resources such as images, colors, strings.
- `SwiftLint` is used to lint the code.
- `Xcodegen` is used to generate project (`project.pbxproj`) based on YAML files.

# Tests
This application utilizes the `XCTest` framework for testing purposes. 
All objects from the **Data Source**, **Application**, and **ViewModels** from the presentation layer are fully tested.

The application is informed about the type of tests via `ProcessInfo` `launchArguments`, which are defined in the project `Scheme`.

### Unit Tests
- Tests are structured following the `Given-When-Then` convention, ensuring clear and understandable test cases for various scenarios.
- Assertions in tests are handled by `XCTAssert()` functions.
- Asynchronus tests are achived by `XCTestExpectation` classes.

### UI Tests
#### Network Mocking
To mock a network connections during UI tests, a local `WireMock` server is used.

The `WireMock` server is started before the UI tests begin and it is shut down after the tests are completed.

The server’s response data and behavior are defined in the `__files` and `mappings` in the `WireMock` directory.

Why so complcated 😀?

Setting up a local server basically does not require changes to the application source code, so it works the same way as the release version of the application. The defined server responses are in the same form as the responses of the real server. This ensures that the tests are able to check the correctness of decoding, mapping data and etc.
The application runs and behaves during UI tests exactly as it would in a real-world scenario, providing reliable and comprehensive test results.

#### Snapshot Testing
For quick and efficient validation of data display correctness, snapshot tests are performed.

During the tests, the current state of the application’s UI is captured using: `XCUIScreen.main.screenshot()`.
Then the captured screenshot is compared to baseline images stored in the `__Snapshots__` directory, located in the UI test directory.
Discrepancies between the current and baseline images indicate visual regressions.

To achieve maximum precision of the compared images (98%), the simulator selected to handle them has the status bar and appearance parameters changed before the UI tests.

# CI/CD
### UI Tests
During tests conducted on a virtual machine, there is no possibility to view simulator screenshots. In order to be able to view simulator screenshots in case of UI snapshots tests failure, after them, simulator failed snapshots are moved to the `UITestsSnapshots` directory. Content of this directory becomes a `Github Action` artifact and is available for download after the pipeline is completed.

### Danger
To automate the Code Review process, the `Danger` tool is used. The `Xcode-Summury` plugin allows you to display test results, errors, and warnings in the code generated by `Xcode` and `SwiftLint` in Pull-request comments.

`Xcode-Summury` is based on the `xcresult` file. The project contains a separate scheme for UI tests and unit tests. In order not to have another, common scheme, both test schemes build the project in the same configuration, then the tests are execute. A separate `xcresult` file is generated for each test. After all, both files are merged using the `xcresulttool` tool.


# Tools and dependencies
- Danger: https://github.com/danger/danger
- Danger Xcode Summary: https://github.com/diogot/danger-xcode_summary
- SwiftLint: https://github.com/realm/SwiftLint
- SwiftGen: https://github.com/SwiftGen/SwiftGen
- XcodeGen: https://github.com/yonaskolb/XcodeGen
- SwiftSnapshotTesting: https://github.com/pointfreeco/swift-snapshot-testing
- WireMock: https://github.com/wiremock/wiremock
- Alamofire: https://github.com/Alamofire/Alamofire
