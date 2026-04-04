# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is bloggen

A macOS command-line tool (Swift) that generates a static blog from Markin-formatted markdown posts and HTML templates. It reads a `blogfile.json` config, parses posts organized in date-named directories, and renders them to HTML using TemplateKit with `{{ }}` delimiters.

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
  - `Blog` — Loads posts from date-named directories (e.g. `2024-01-15/`), parses `.md` files with Markin, extracts title (first H1), preamble (first paragraph), TOC, images, and body HTML.
  - `BlogRenderer` — Renders posts using TemplateKit templates, writes HTML output and copies local images.
  - `BlogPost` — Post model. Generates URL-safe relative paths from date + title.

## Key Dependencies

- **Markin** (`apparata/Markin`) — custom markdown-like parser (not CommonMark). Posts are written in Markin format.
- **TemplateKit** (`apparata/TemplateKit`) — templates use `{{` / `}}` tag delimiters.
- **SystemKit** (`apparata/SystemKit`) — provides `Path` type used throughout for file system operations.

## Blog Content Structure

Posts live in date-named subdirectories (format `yyyy-MM-dd`) under the configured posts directory. Each subdirectory contains `.md` files (Markin format) and associated images. The first H1 becomes the title; the first paragraph becomes the preamble; both are removed from the body HTML.
