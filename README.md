<h1 align="center">Air Quality</h1>
<h3 align="center">App to check the air quality</h3>

</br>

<p align="center">
<img alt="Swift Version" src="https://img.shields.io/badge/5.10-red?style=flat&logo=Swift&logoColor=white&label=Swift&labelColor=light_gray&color=orange"/>
<img alt="Platforms" src="https://img.shields.io/badge/iOS_17.0%2B-red?style=flat&logo=apple&logoColor=white&label=platforms&labelColor=light_gray&color=blue"/>
</a>

</br>

## Architecture

This application follows the Clean Architecture principles.

Check out more: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

## Presentation Layer

The presentation layer of this application is built entirely using `SwiftUI` in combination with the `MVVM+C` (Model-View-ViewModel-Coordinator) pattern.

The navigation in this app is powered by SwiftUI's `NavigationView` with `NavigationPath`.

## Concurrent code

The concurrent code in this project is implemented using the `Swift Concurrency` library. `Strict Concurrency Checking` setting is set to `Complete`.
All cases which **cannot be written** using the Concurrency library, are achieved by `Combine` library.

## Tests

This application utilizes the `XCTest` framework for testing purposes. 
All objects from the **Data Source**, **Application**, and **ViewModels** from the presentation layer are fully tested. 
The tests are structured following the `Given-When-Then` convention, ensuring clear and understandable test cases for various scenarios.