# Hugo Blog Cheatsheet

## Development Server

Start the local server with auto-refresh:

```bash
nix-shell --run "hugo server --buildDrafts --bind 0.0.0.0"
```

Options:
- `--buildDrafts`: Include draft posts
- `--bind 0.0.0.0`: Allow access from any network interface
- Add `-D` as shorthand for `--buildDrafts`

The site will be available at `http://localhost:1313`

## Adding a New Article

Create a new blog post:

```bash
nix-shell --run "hugo new content posts/my-article-title.md"
```

This creates a file at `content/posts/my-article-title.md` with front matter:

```markdown
+++
date = '2026-05-08T23:19:05+02:00'
draft = true
title = 'My Article Title'
+++

Your content here...
```

**Important**: Set `draft = false` when ready to publish.

### Front Matter Options

```toml
+++
date = '2026-05-08T23:19:05+02:00'
draft = false
title = 'Article Title'
description = 'Brief description for SEO'
tags = ['go', 'kubernetes', 'devops']
categories = ['tutorials']
+++
```

## Adding a Category

Categories are created automatically when used in front matter:

```toml
+++
categories = ['tutorials', 'deep-dive']
+++
```

To create a category landing page:

```bash
nix-shell --run "hugo new content categories/tutorials/_index.md"
```

Edit `content/categories/tutorials/_index.md`:

```markdown
+++
title = 'Tutorials'
+++

Collection of tutorial articles.
```

## Building for Production

Build the static site:

```bash
nix-shell --run "hugo --gc --minify"
```

Output will be in `./public/`

## Useful Commands

```bash
# List all content
nix-shell --run "hugo list all"

# List draft posts
nix-shell --run "hugo list drafts"

# Check Hugo version
nix-shell --run "hugo version"
```
