# Contributing

## Prerequisites

- Ruby `3.3.4`
- Bundler

## Local Setup

1. Install the Ruby version in `.ruby-version`.
2. Change into the repository root.
3. Install dependencies with `bundle install`.
4. Start a local preview with `bundle exec jekyll serve` or run a one-off build with `bundle exec jekyll build`.

## Branch Workflow

- Branch from `main`.
- Keep new work local until it is ready to push.
- Use focused branch names for discrete changes.

## Editing Rules

- Edit source files only.
- Do not hand-edit `_site/`.
- Keep front matter valid YAML.
- Reuse existing URL and asset path patterns unless the task requires a broader refactor.
- For layout or style changes, verify the affected pages visually and capture screenshots for review.

## Validation

Run these commands before handing work off:

```bash
bundle install
bundle exec jekyll build
```

Use `bundle exec jekyll serve` for manual browser checks when the change affects layout, styling, navigation, or JavaScript behavior.

## Review Expectations

- Include the exact commands you ran.
- Call out any pages that need manual visual review.
- Follow `.github/code_review.md` for Jekyll-specific review priorities.
