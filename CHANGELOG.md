# Changelog

## 0.1.2

### Added
- Created `CONTRIBUTING.md` with project guidelines and PR process
- Added `CODE_OF_CONDUCT.md` (Contributor Covenant)
- Added `ARCHITECTURE.md` explaining engine-first design and rendering pipeline
- Improved README with Contributing and Stability & Versioning sections

### Documentation & Hygiene
- Marked internal classes in `lib/src/` as internal implementation details
- Enhanced example app with helpful comments for future contributors
- **No breaking changes** - Behavior and public APIs remain fully stable

## 0.1.1

### Fixed
- Resolved deprecated Matrix4 scaling API usage
- Fixed internal import issues and warnings
- Package description updated
- No public API changes

## 0.1.0

### Initial release
- High-performance trading chart engine for Flutter
- CustomPainter-based candlestick rendering
- Viewport-driven drawing (only visible data rendered)
- Cached price scale and coordinate mapping
- Pan, zoom, and double-tap gesture support
- Fully customizable chart style and layout
- Engine-first architecture (Data → Engine → Rendering)
