# 🧑‍🎨 Avatar Builder

A SwiftUI avatar builder that lets users create and customize their own little digital self — pick a shape, choose colors, style the hair, eyes, and mouth, and you're done. The result shows up across the app wherever a personal touch is needed.

## Features

- Shape selection (circle, rounded rect, and more)
- Full color palette control — background, skin, hair, and accent colors
- Facial feature customization — hair, eyes, and mouth styles
- Live preview with instant updates
- Export-ready avatar for use across the app

## Getting Started

1. Clone the repo and open `AvatarBuilder.xcodeproj` in Xcode
2. Select your target (iOS or macOS)
3. Hit **Run** — no extra setup needed

## Developer Guide

The app follows a simple MVVM-ish pattern. `AvatarModel` holds all the avatar state using nested enums for each customizable feature. `AvatarControls` binds directly to the model so edits are immediately reflected everywhere.

Want to add a new style option? Drop it into the relevant enum in `AvatarModel` and it'll automatically appear in the picker — no extra wiring needed.
