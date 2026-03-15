# AGENTS.md

This repository is a Jekyll site intended to be edited from source and built locally or in CI.

## Repo Map

- `index.md`, `contact/`, `news/`, `research/`, `publications/`, `teaching/`, `team/`: top-level pages and sections.
- `_team/`: team member collection entries grouped by role.
- `_publications/`: publication collection entries used by the publications pages.
- `_layouts/default.html`: shared page shell, navigation, theme toggle, and global script includes.
- `assets/css/style.css`: site styling.
- `assets/js/molecular-viewer.js`: client-side viewer behavior.
- `_templates/publications-template.md`: starting point for new publication entries.
- `_site/`: generated output only. Never edit it by hand and do not review it as source.

## Source-Only Rules

- Edit source files only. Treat `_site/`, `.jekyll-cache/`, and other build artifacts as disposable output.
- Preserve valid YAML front matter on Markdown content files.
- Keep links and asset references consistent with the existing Jekyll site structure.
- When changing layouts or styles, prefer patterns already used in `_layouts/default.html` and `assets/css/style.css`.
- Do not change dependency or Pages runtime files unless the task requires it.

## Standard Commands

Run all commands from the repository root.

- Install gems: `bundle install`
- Local build check: `bundle exec jekyll build`
- Local preview server: `bundle exec jekyll serve`

Run `bundle exec jekyll build` after every source change. For layout or style changes, also do a browser check on the affected pages and capture screenshots if the change will be reviewed by others.

## Done Criteria

- The changed pages build successfully with `bundle exec jekyll build`.
- No generated files are committed from `_site/` or Jekyll caches.
- Content edits keep front matter, links, and section structure valid.
- Visual changes include a quick manual check for desktop and mobile layouts.

## Review Focus

Use `.github/code_review.md` as the shared review checklist for both humans and agents.
