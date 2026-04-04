# bloggen

A static blog generator for macOS. Takes blog posts written in [Markin](https://github.com/apparata/Markin) format, applies HTML templates, and outputs a complete static blog.

## Installation

Requires Swift 6.3+ and macOS 26+.

```sh
swift build --configuration release
cp .build/release/bloggen ~/bin/bloggen
```

Or use the convenience script:

```sh
./build-and-install.sh
```

## Usage

```sh
bloggen <path>
bloggen --verbose <path>
```

`<path>` can be either a directory containing a `blogfile.json` or a direct path to the config file.

## Project Structure

A bloggen project looks like this:

```
my-blog/
  blogfile.json
  templates/
    blog.html
    post.html
  posts/
    2024-01-15/
      my-first-post.md
      photo.jpg
    2024-03-22/
      another-post.md
```

## blogfile.json

The config file defines where posts live, where to write output, and which templates to use.

```json
{
    "posts": "posts",
    "output": "/path/to/output",
    "templates": {
        "blog": {
            "template": "blog.html",
            "name": "index",
            "type": "html"
        },
        "post": {
            "template": "post.html",
            "type": "html"
        }
    }
}
```

| Field | Description |
|-------|-------------|
| `posts` | Directory containing post subdirectories (relative to the config file) |
| `output` | Output directory path (absolute) |
| `templates.blog.template` | Filename of the blog index template (in the `templates/` directory) |
| `templates.blog.name` | Output filename for the index page (defaults to `"index"`) |
| `templates.blog.type` | File extension for the index page (e.g. `"html"`) |
| `templates.post.template` | Filename of the individual post template |
| `templates.post.type` | File extension for individual post pages |

## Writing Posts

Posts are written in [Markin](https://github.com/apparata/Markin) format, a Markdown-like syntax. Each post is a `.md` file inside a date-named directory under `posts/`. The directory name must follow the `yyyy-MM-dd` format (e.g. `2024-01-15`).

You can place multiple posts in the same date directory and include images alongside the markdown files. Local images referenced in a post are automatically copied to the output directory.

### Post structure

The first H1 header becomes the post title and the first paragraph becomes the preamble (summary). Both are extracted and removed from the body content.

```markdown
# My Post Title

This is the preamble that appears as a summary on the index page.

## First Section

The rest of the content becomes the post body.

![A photo](photo.jpg)
```

### Markin syntax reference

| Element | Syntax |
|---------|--------|
| Headers | `# H1` through `###### H6` |
| Bold | `*bold text*` |
| Italic | `_italic text_` |
| Links | `[caption](url)` |
| Images | `![alt text](image.jpg)` |
| Inline code | `` `code` `` |
| Code blocks | ```` ```language ```` ... ```` ``` ```` |
| Unordered lists | `- item` (indent 4 spaces to nest) |
| Ordered lists | `1. item` (indent 4 spaces to nest) |
| Block quotes | `> quoted text` |
| Horizontal rule | `---` |
| Table of contents | `%TOC` |

## Writing Templates

Templates are HTML files that use `{{ }}` delimiters for dynamic content. They are placed in a `templates/` directory next to the config file.

### Blog index template

The blog index template receives a `posts` array. Loop over it to build the index page.

```html
<html>
<body>
    {{for post in posts}}
    <article>
        <h2><a href="{{post.relativeURL}}">{{post.title}}</a></h2>
        <time>{{post.dateText}}</time>
        <p>{{post.preamble}}</p>
    </article>
    {{end}}
</body>
</html>
```

### Post template

The post template receives a single `post` object.

```html
<html>
<body>
    <article>
        <h1>{{post.title}}</h1>
        <time>{{post.dateText}}</time>
        <nav>{{post.toc}}</nav>
        {{post.html}}
    </article>
</body>
</html>
```

### Available post properties

| Property | Description |
|----------|-------------|
| `title` | Post title (from the first H1 header) |
| `dateText` | Formatted date string (e.g. "Jan 15, 2024") |
| `preamble` | Summary text (from the first paragraph) |
| `html` | Rendered HTML body (without the title and preamble) |
| `toc` | Generated table of contents HTML with anchor links |
| `relativeURL` | Relative path to the post (e.g. `posts/2024-01-15/my-post-title.html`) |

### Template syntax

| Feature | Syntax |
|---------|--------|
| Variable | `{{variable}}` or `{{object.property}}` |
| For loop | `{{for item in collection}}` ... `{{end}}` |
| Conditional | `{{if variable}}` ... `{{end}}` |
| Conditional with else | `{{if variable}}` ... `{{else}}` ... `{{end}}` |
| Import | `{{import "partial.html"}}` |
| Transformer | `{{#lowercased variable}}` |

Built-in transformers: `lowercased`, `uppercased`, `uppercasingFirstLetter`, `lowercasingFirstLetter`, `trimmed`, `removingWhitespace`.

## Output

The generated blog is written to the configured output directory:

```
output/
  index.html              # Blog index page
  posts/
    2024-01-15/
      my-post-title.html   # Individual post
      photo.jpg             # Copied images
    2024-03-22/
      another-post.html
```

Post URLs are generated from the date and a URL-safe version of the title (lowercased, non-alphanumeric characters replaced with hyphens).

## Dependencies

- [Markin](https://github.com/apparata/Markin) - Markdown-like parser
- [TemplateKit](https://github.com/apparata/TemplateKit) - Template engine
- [SystemKit](https://github.com/apparata/SystemKit) - File system utilities
- [CollectionKit](https://github.com/apparata/CollectionKit) - Collection extensions
- [TextToolbox](https://github.com/apparata/TextToolbox) - String utilities
- [swift-argument-parser](https://github.com/apple/swift-argument-parser) - CLI argument parsing
