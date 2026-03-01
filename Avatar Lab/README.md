# Project Overview and Technical Guide

This document outlines the goal of the project, how it’s architected, current issues blocking progress (including the “Invalid redeclaration of 'PlatformImage'” error), and practical tips for moving forward. It’s written to help both current and future contributors quickly understand the system and make effective changes.

## Project Goal

The project is an avatar builder/editor built with SwiftUI. Users can customize:

- Shape of the avatar (e.g., circle, rounded rect, etc.)
- Color palette (background, skin, hair, accent)
- Facial features (hair style, eye style, mouth style)

The outcome is a rendered avatar that can be previewed/exported and used across the app (e.g., profile, sharing, etc.). The controls surface a clean set of options and use bindings into a central `AvatarModel`.

## High-Level Architecture

The architecture follows a clean MVVM-ish SwiftUI approach:

- **Model: `AvatarModel`**
  - Holds the avatar’s design state.
  - Uses nested enums for option sets:
    - `ShapeStyleOption`
    - `HairStyle`
    - `EyeStyle`
    - `MouthStyle`
    - `ColorOption`
  - Includes computed properties for UI use (e.g., `swiftUIColor`, `hex`).
- **View: `AvatarControls`**
  - A SwiftUI view that binds to `AvatarModel` via `@Binding var model`.
  - Presents grouped controls:
    - Shape selection via segmented `Picker`.
    - Colors via custom `ColorPickerLabel` controls.
    - Features via multiple `Picker`s for hair, eyes, mouth.
- **Subviews/Helpers: `ColorPickerLabel`**
  - A small SwiftUI component that:
    - Shows a swatch, label, and the hex string.
    - Presents a `ColorPicker` in a sheet to update color.
    - Bridges between `AvatarModel.ColorOption` and `SwiftUI.Color` for user editing.

### Data Flow

- The view uses bindings (`$model.*`) so user edits immediately propagate back to the `AvatarModel`.
- `ColorPickerLabel` temporarily stores a SwiftUI `Color` in `@State` for presentation (`swiftUIColor`), then commits back to the model as a `.custom(r:g:b:)` color when the user taps “Done”.
- Enumerations for styles drive the Picker options with `ForEach(...allCases)` for a simple, type-safe selection list.

### Rendering (Likely)

A companion view renders the avatar based on `AvatarModel` selections:
- A base shape (from `shape`)
- Layers for skin, hair, eyes, mouth
- Color application from `ColorOption` values

If the project targets multiple platforms (iOS, macOS, etc.), there may be an abstraction for images (e.g., `PlatformImage`) to bridge `UIImage` and `NSImage` for export or previews.

## Current Issues

### 1) “Invalid redeclaration of 'PlatformImage'”

This error indicates that a type named `PlatformImage` is declared more than once in the build. Common causes:

- Duplicate type definitions across files or targets:
  - Example: A `typealias PlatformImage = UIImage` in one file, and another with the same alias or a struct/class named `PlatformImage` in another file.
- Conditional compilation overlaps:
  - Two files each define `PlatformImage`, each wrapped in different `#if os(...)` blocks, but both end up compiled for the same target.
- Mixed modules:
  - The same type defined in the app target and in a linked framework or test target with overlapping visibility.

How to resolve:

- Search the project for all declarations of `PlatformImage`.
- Consolidate to a single definition, and use conditional compilation to switch between `UIImage` and `NSImage`:
  ```swift
  #if canImport(UIKit)
  import UIKit
  public typealias PlatformImage = UIImage
  #elseif canImport(AppKit)
  import AppKit
  public typealias PlatformImage = NSImage
  #endif
