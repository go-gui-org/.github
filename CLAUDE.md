# CLAUDE.md — go-gui-org

This is the `.github` repository for the **go-gui-org** GitHub organization.
Organization-level defaults (profile README, issue/PR templates, CI workflows) live
here and propagate to all sibling repositories.

## Organization purpose

Building a modern, cross-platform GUI framework for Go — `go-gui` — along with its
companion libraries.

## Sibling projects

| Repo | Purpose |
|------|---------|
| **go-gui** | Core framework — widgets, constraint layout, event system, GPU-accelerated retained-mode scene graph |
| **go-glyph** | Browser-quality text rendering — bidi, multi-grapheme clusters, complex scripts — plus vector icons and glyph rasterization |
| **go-charts** | Declarative charting — line, bar, area, pie, scatter, candlestick — incremental updates for real-time dashboards |
| **go-maps** | Tiled raster/vector map widget with projection handling, markers, and geospatial overlays |
| **go-term** | Embeddable terminal emulator — PTY, ANSI/VT parser, render surface as a go-gui widget |
| **go-edit** | Text editing — single-line to multi-cursor code editor, piece-table undo, syntax highlighting, completion hooks |

All sibling repos live under `github.com/go-gui-org/<repo>` and import each other
under the `github.com/go-gui-org/` module path.

## Repository layout

```
.github/          GitHub org-level config (profiles, templates, workflows)
README.md         Organization profile (shown on github.com/go-gui-org)
CLAUDE.md         This file
```

## Conventions (applies to all sibling repos)

- Go modules rooted at `github.com/go-gui-org/<repo>`
- Cross-platform: macOS, Windows, Linux as first-class targets
- Public API stability is paramount — breaking changes require coordination across
  sibling repos
- README.md in each repo documents its scope, API surface, and relationship to
  `go-gui` core
