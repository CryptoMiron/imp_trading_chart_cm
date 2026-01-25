# Contributing to imp_trading_chart

First off, thank you for considering contributing to `imp_trading_chart`! It's people like you that make the open-source community such an amazing place to learn, inspire, and create.

## Project Purpose
`imp_trading_chart` is a high-performance trading chart engine for Flutter, inspired by TradingView Lightweight Charts. It focuses on efficiency, low-level rendering (CustomPainter), and a clean separation between data and rendering logic.

## Folder Structure
- `lib/`: Contains the package source code.
  - `imp_trading_chart.dart`: The main entry point and public API definition.
  - `src/`: Internal implementation details (Internal API).
    - `data/`: Data models (Candle, Enums).
    - `engine/`: Core logic (Viewport, PriceScale, ChartEngine).
    - `rendering/`: Custom painters and renderers.
    - `widgets/`: The main `ImpChart` widget.
- `example/`: A showcase app demonstrating various chart configurations.
- `screenshots/`: Visual assets for documentation.

## How to Run the Example App
1. Clone the repository.
2. Navigate to the `example/` directory: `cd example`
3. Run `flutter pub get`.
4. Run the app: `flutter run`.

## How to Add Features Safely
1. **Check the Engine First**: Most logic should reside in the `engine/` layer.
2. **Minimize Widget Complexity**: Keep the `ImpChart` widget as a thin wrapper around the engine and renderer.
3. **Internal vs Public**: Only export things in `lib/imp_trading_chart.dart` if they are meant to be stable public APIs. Everything else stays in `src/`.
4. **Performance**: Always consider the rendering loop. Avoid `DateTime` math or heavy object creation inside `paint()` methods.

## Coding Conventions
- Follow official [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style).
- Use descriptive names for variables and functions.
- Document public APIs with triple-slash `///` comments.
- Keep classes focused on a single responsibility.

## How to Submit PRs
1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`flutter test`).
5. Make sure your code lints (`dart analyze`).
6. Issue that PR!
