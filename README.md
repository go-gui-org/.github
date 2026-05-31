# go-gui

A modern, cross-platform graphical user interface framework for Go. go-gui provides
native-feeling widgets, flexible layout, and GPU-accelerated rendering across macOS,
Windows, and Linux — no CGo, no JavaScript bridge, just Go.

## Libraries

**go-gui** — Core framework providing the widget set, constraint-based layout engine,
event system, and GPU-accelerated rendering backend. All drawing is backed by a
retained-mode scene graph that batches draw calls and avoids redundant raster work.
Widgets are composable and stylable via a CSS-like property system, making it
straightforward to build interfaces that feel native on each platform without
platform-specific code paths.

**go-glyph** — Text and icon rendering library built on the same pipeline as go-gui.
Handles bidirectional text, multi-grapheme clusters, and complex scripts to deliver
browser-quality text layout. Ships with a curated set of general-purpose icons and
supports loading third-party icon sets (Material, Tabler, Lucide). Glyph-level
metrics, shaping, and rasterization are exposed for applications that need precise
control over text placement — code editors, design tools, and typesetting.

**go-charts** — Declarative charting library for data visualization. Supports line,
bar, area, pie, scatter, and candlestick charts with configurable axes, legends, and
tooltips. Renders via the go-gui scene graph, so charts integrate directly into
application windows and respond to the same theme and styling system. Designed for
both real-time dashboards (incremental data updates without full redraw) and static
report generation.

**go-maps** — Map widget that renders tiled raster and vector layers with marker and
overlay support. Handles projection, coordinate systems, and level-of-detail tile
selection so developers can drop a map into an application without managing map
service protocols. Suitable for geospatial dashboards, asset tracking, and
location-aware tools.

**go-term** — Embeddable terminal emulator widget. Provides a PTY layer, ANSI/VT
escape sequence parser, and a render surface that integrates into go-gui layouts.
Useful for developer tools, deployment consoles, and any application that needs a
first-class command-line interface alongside graphical panels.

**go-edit** — Text editing components ranging from a simple line editor to a
multi-cursor code editor with syntax highlighting, code completion hooks, and
configurable key bindings. Uses a piece-table data structure for efficient undo and
concurrent edits. Integrates with go-glyph for glyph-level cursor placement and text
measurement.
