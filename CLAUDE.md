# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is bloggen

A macOS command-line tool (Swift 6.3, macOS 26) that generates a static blog from Markin-formatted posts and HTML templates. Reads a `blogfile.json` config, parses posts from date-named directories, and renders them to HTML using TemplateKit with `{{ }}` delimiters.

## Build & Run

```sh
swift build                          # debug build
swift build --configuration release  # release build
./build-and-install.sh               # release build + install to ~/bin
```

Usage: `bloggen [--verbose] <path-to-blogfile.json-or-directory>`

## Architecture

Two targets:
- **bloggen** — CLI entry point (`Sources/bloggen/BloggenCommand.swift`). Uses swift-argument-parser with `@main`. Loads `blogfile.json`, delegates to `bloggenKit.buildBlog()`.
- **bloggenKit** — Library with all logic:
  - `BlogConfig` — Codable config model parsed from `blogfile.json`. Defines posts directory, output directory, and template paths for blog index and individual posts.
  - `Blog` — Loads posts from date-named directories (e.g. `2024-01-15/`), each containing numbered subdirectories (`0/`, `1/`, ...) — one per post — with a `.md` file and any referenced images. Parses the markdown with Markin, extracts title (first H1), preamble (first paragraph), TOC, images, and body HTML. Within a date, posts are ordered by their numeric index.
  - `BlogRenderer` — Renders posts using TemplateKit templates, writes HTML output and copies local images. Blog index template receives a `posts` array; post template receives a single `post` object. Properties resolved via `Mirror` reflection.
  - `BlogPost` — Post model with properties: `title`, `dateText`, `index`, `preamble`, `html`, `toc`, `relativeURL`, `images`. Generates URL-safe relative paths of the form `posts/<date>/<index>/<title-slug>.html`. Sort order is (date, index) ascending; the post list is reversed before rendering so the newest entries appear first.

## Key Dependencies

- **Markin** (`apparata/Markin` 1.0.1) — custom markdown-like parser (not CommonMark). `*bold*`, `_italic_`, `![img](url)`, `[link](url)`, code blocks, lists, block quotes. First H1 = title, first paragraph = preamble.
- **TemplateKit** (`apparata/TemplateKit` 0.7.3) — templates use `{{` / `}}` delimiters. Supports `{{for x in y}}...{{end}}`, `{{if x}}...{{else}}...{{end}}`, `{{import "file"}}`, `{{#transformer variable}}`.
- **SystemKit** (`apparata/SystemKit` 1.8.1) — provides `Path` type used throughout for file system operations.
- **CollectionKit** (`apparata/CollectionKit` 1.1.1) — collection extensions (used for `removeFirst` with predicate).
- **TextToolbox** (`apparata/TextToolbox` 1.4.0) — string utilities (`trimmed()`).
- **swift-argument-parser** (1.7.1) — CLI argument parsing.
